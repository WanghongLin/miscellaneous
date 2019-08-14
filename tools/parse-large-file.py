#!/usr/bin/evn python
# -*- encoding: utf-8 -*-
#
# Simple example for processing large file in multiple threads line by line
#
# Copyright 2019 Wanghong Lin
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

import threading
import multiprocessing
import itertools
import subprocess


def get_file_lines(file_name):
    """
    Efficient way to get total line of a file
    :param file_name: full file path
    :return: file total length
    """
    p = subprocess.Popen(['wc', '-l', file_name], stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    result, err = p.communicate()
    if p.returncode != 0:
        raise IOError(err)
    return int(result.strip().split()[0])


def parse_file_chunk(input_file, start_line_inclusive, stop_line_exclusive, result):
    with open(input_file, 'r') as f:
        for l in itertools.islice(f, start_line_inclusive, stop_line_exclusive):
            l.split(',')
            # add your other processing logic here
    if result:
        result.append('task done with result')


def parse_large_file_via_multiprocessing(file_path):
    """
    Parse large file via multiprocessing
    :param file_path:
    :return:
    """
    file_lines = get_file_lines(file_path)
    number_of_tasks = multiprocessing.cpu_count()/2
    slice_lines = file_lines / number_of_tasks

    manager = multiprocessing.Manager()
    result = manager.list()  # be caution to use Queue, the join will hang if the queue is full for passing large data
    processes = []
    for i in range(number_of_tasks):
        start_line = i*slice_lines
        stop_line = max((i+1)*slice_lines, file_lines) if i+1 == number_of_tasks else (i+1)*slice_lines
        p_name = 'Process {}'.format(i)
        print('{} {} -> {} of {}'.format(p_name, start_line, stop_line, file_lines))
        p = multiprocessing.Process(target=parse_file_chunk, name=p_name,
                                    args=(file_path, start_line, stop_line, result))
        processes.append(p)
        p.start()

    [p.join() for p in processes]


def parse_large_file_via_threading(file_path):
    """
    This is not real multiple threads due to GIL (Global Interrupt Lock) in python
    :param file_path: absolute file path
    :return: None
    """
    file_lines = get_file_lines(file_path)
    number_of_threads = multiprocessing.cpu_count()/2
    slice_lines = file_lines / number_of_threads

    threads = []
    for i in range(number_of_threads):
        start_line = i * slice_lines
        stop_line = max((i + 1) * slice_lines, file_lines) if i + 1 == number_of_threads else (i + 1) * slice_lines
        t = threading.Thread(target=parse_file_chunk, name='Thread {}'.format(i),
                             args=(file_path, start_line, stop_line, []))
        print('{0} line range {1} -> {2}'.format(t.name, start_line, stop_line))
        threads.append(t)
        t.start()

    [t.join() for t in threads]


if __name__ == '__main__':
    import argparse
    import time
    import datetime
    import sys

    parser = argparse.ArgumentParser(prog='Large file parse example')
    parser.add_argument('--threading', default=False, action='store_true',
                        help='Use threading to parse file, default is no')
    parser.add_argument('input', nargs=1, help='Input file path')

    args = parser.parse_args(sys.argv[1:])

    if args.threading:
        start_time = time.time()
        parse_large_file_via_threading(args.input[0])
        print('Time took for threading {}'.format(datetime.timedelta(seconds=(time.time()-start_time))))
    else:
        start_time = time.time()
        parse_large_file_via_multiprocessing(args.input[0])
        print('Time took for processing {}'.format(datetime.timedelta(seconds=(time.time()-start_time))))
