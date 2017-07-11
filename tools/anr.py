#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 
# Simple ANR analyzer, use graphviz to output for every analyzed process
# Copyright 2017 Wanghong Lin
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

import argparse
import re
import sys

has_graphviz = False
try:
    import graphviz
    has_graphviz = True
except ImportError:
    has_graphviz = False
    print 'No graphviz installation found'
    print 'Install the package'
    print ''
    print '\tpip install graphviz\n'
    print 'If you want to output ANR dependency graphic as pdf'
    print ''

RE_PROCESS_START = re.compile('.*pid (\d+) at.*')
RE_PROCESS_NAME = re.compile('Cmd line: (\S+)')
RE_PROCESS_END = re.compile('.*end (\d+).*')
RE_THREAD_START = re.compile('(.*) prio=(\d+) tid=(\d+) (\S+)')
RE_ANR_PATTERN = re.compile(r'.*waiting to lock.*held by (?:thread |tid=)(\d+)', re.MULTILINE | re.DOTALL)


def make_html_colored_text(color_notation, text):
    return '<<font color="{0}">{1}</font>>'.format(color_notation, text)


class ThreadBlock(object):
    def __init__(self):
        super(ThreadBlock, self).__init__()
        self.title = ''
        self.priority = 0
        self.tid = 0
        self.thread_name = ''
        self.state = ''
        self.thread_stack = ''


class Anr(object):
    def __init__(self):
        super(Anr, self).__init__()
        self.anr_thread = ThreadBlock()
        self.held_by_thread = ThreadBlock()
        self.depends_on_anr = None


class ProcessBlock(object):
    def __init__(self):
        super(ProcessBlock, self).__init__()
        self.pid = 0
        self.name = ''
        self.process_header = ''
        self.thread_blocks = []


def get_anr_for_process(process_b):
    anr = None
    anrs = []
    for thread_b in process_b.thread_blocks:
        anrm = RE_ANR_PATTERN.match(thread_b.thread_stack)
        if anrm:
            anr = Anr()
            anr.anr_thread = thread_b
            held_by_tid = anrm.group(1)

            for held_by_thread in process_b.thread_blocks:
                if held_by_thread.tid == held_by_tid:
                    anr.held_by_thread = held_by_thread
                    # print '\nFound ANR in ', thread_b.tid, ', held by tid ', held_by_tid

            anrs.append(anr)

    return anrs


def build_anr_hierarchy(in_anrs):
    for in_anr in in_anrs:
        for in_anr2 in in_anrs:
            if in_anr.held_by_thread.tid == in_anr2.anr_thread.tid:
                in_anr.depends_on_anr = in_anr2

    return in_anrs


def analyze_anr(anr_file, out_format):
    with anr_file as anr:

        handle_process_header = False
        handle_thread_stack = False

        pbs = []
        for line in anr.readlines():

            psm = RE_PROCESS_START.match(line)
            pem = RE_PROCESS_END.match(line)
            tsm = RE_THREAD_START.match(line)

            if psm:
                pb = ProcessBlock()
                pb.pid = psm.group(1)
                pbs.append(pb)
                handle_process_header = True
                handle_thread_stack = False
                continue

            if handle_process_header:
                pbs[-1].process_header = pbs[-1].process_header + line
                pnm = RE_PROCESS_NAME.match(line)
                if pnm:
                    pbs[-1].name = pnm.group(1)

            if tsm:
                handle_process_header = False
                handle_thread_stack = True
                tb = ThreadBlock()
                tb.title = tsm.group(0)
                tb.thread_name = tsm.group(1)
                tb.priority = tsm.group(2)
                tb.tid = tsm.group(3)
                tb.state = tsm.group(4)
                pbs[-1].thread_blocks.append(tb)
                continue

            if handle_thread_stack:
                pbs[-1].thread_blocks[-1].thread_stack = pbs[-1].thread_blocks[-1].thread_stack + line

        for out_pb in pbs:
            if len(out_pb.name) > 0:
                anr_list = get_anr_for_process(out_pb)

                if len(anr_list) is 0:
                    continue

                anr_new_list = build_anr_hierarchy(anr_list)

                print out_pb.name, 'tid =', out_pb.pid, 'total threads =', len(out_pb.thread_blocks), 'anrs =', len \
                    (anr_list), len(anr_new_list)

                if has_graphviz:
                    dot = graphviz.Digraph(comment='ANR output for {0}'.format(out_pb.name), graph_attr={'rankdir': 'LR'}, format=out_format)

                for oanr in anr_new_list:

                    if has_graphviz:
                        dot.node(oanr.anr_thread.title, oanr.anr_thread.thread_stack, _attributes={'xlabel': oanr.anr_thread.title})
                        dot.node(oanr.held_by_thread.title, oanr.held_by_thread.thread_stack, _attributes={'xlabel': make_html_colored_text('#ff0000', oanr.held_by_thread.title)})
                        dot.edge(oanr.anr_thread.title, oanr.held_by_thread.title)

                    out = 'ANR in thread {0} held by tid {1}'.format(oanr.anr_thread.tid, oanr.held_by_thread.tid)
                    next_anr = oanr.depends_on_anr
                    while next_anr is not None:
                        appended_out = ', tid {0} held by tid {1}'.format(next_anr.anr_thread.tid, next_anr.held_by_thread.tid)
                        out = out + appended_out
                        next_anr = next_anr.depends_on_anr
                    print out

                if has_graphviz:
                    out_gv_file = '{0}_{1}.gv'.format(out_pb.name, out_pb.pid)
                    print 'render to file', out_gv_file
                    dot.render(out_gv_file)

    pass


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Analyze ANR from traces.txt, output as pdf by graphviz')
    parser.add_argument('--format', choices=['ps', 'pdf', 'svg', 'png', 'gif', 'jpg'], help='Specify the output format')
    parser.add_argument('file', type=argparse.FileType('r'), default=sys.stdin, help='Absolute path to traces.txt')
    args = parser.parse_args()

    analyze_anr(args.file, args.format)


