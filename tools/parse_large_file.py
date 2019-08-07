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


def get_file_lines(f_name):
    """
    Efficient way to get total line of a file
    :param f_name: full file path
    :return: file total length
    """
    p = subprocess.Popen(['wc', '-l', f_name], stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE)
    result, err = p.communicate()
    if p.returncode != 0:
        raise IOError(err)
    return int(result.strip().split()[0])


def perform_parse(*args, **kwargs):
    start = kwargs['start']
    stop = kwargs['stop']
    with open(args[0], 'r') as f:
        for l in itertools.islice(f, start, stop):
            l.split(',')
            # add your other processing logic here


def parse_large_file(file_path):
    file_lines = get_file_lines(file_path)
    number_of_threads = multiprocessing.cpu_count()/2
    slice_lines = file_lines / number_of_threads

    threads = []
    for i in range(number_of_threads):
        start = i * slice_lines
        stop = max((i + 1) * slice_lines, file_lines) if i + 1 == number_of_threads else (i + 1) * slice_lines
        t = threading.Thread(target=perform_parse, args=(file_path,), kwargs={'start': start, 'stop': stop},
                             name='Thread {}'.format(i))
        print('{0} line range {1} -> {2}'.format(t.name, start, stop))
        threads.append(t)
        t.start()

    [t.join() for t in threads]


if __name__ == '__main__':
    parse_large_file('path/to/large_file')
