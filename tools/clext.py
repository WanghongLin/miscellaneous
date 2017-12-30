#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 
# Simple python program to convert OpenCL code to string
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

import os;
import sys;
import argparse;
import re;

EXCLUDE_CODE_PATTERN = [ '#define.*CL_BUILD.*', '.*CL_PARTITION_BY_NAMES_LIST_END_INTEL.*' ]
EXCLUDE_FILE_PATTERN = [ 'cl_platform.h', 'cl_dx9.*intel.h' ]

def is_excluded_in_patterns(s, patterns):
    for p in patterns:
        if re.compile(p).match(s):
            return True
    return False

def main():
    """convert opencl code to string
    :returns: void 

    """
    parser = argparse.ArgumentParser();
    parser.add_argument("clheaders", help="/path/to/clheaders")
    args = parser.parse_args()

    if not os.path.isdir(args.clheaders):
        print 'not a directory {0}'.format(args.clheaders)
        return

    path_to_cl_h = args.clheaders

    success_pattern = re.compile('#define (CL_SUCCESS).*([0-9]+)$')
    handle_pattern = re.compile('#define (CL_\S+)\s+(-[0-9]+)$')

    test_codes = []

    write_lines = []
    write_lines.append('// auto generated from {0}\n'.format(sys.argv[0]))
    write_lines.append('#ifndef __CL_EXT__\n')
    write_lines.append('#define __CL_EXT__\n')
    write_lines.append('\n\n')
    write_lines.append('#include <stdio.h>\n\n\n')
    write_lines.append('/*\n')
    write_lines.append(' * Given a cl code and return a string represenation\n')
    write_lines.append(' */\n')
    write_lines.append('const char* clGetErrorString(int errorCode) {\n')
    write_lines.append('\tswitch (errorCode) {\n')

    for f in os.listdir(args.clheaders):
        if is_excluded_in_patterns(f, EXCLUDE_FILE_PATTERN):
            print 'skip file {0}'.format(f)
            continue
        path_to_cl_h = args.clheaders + os.path.sep + f

        if os.path.isdir(path_to_cl_h):
            print 'skip directory {0}'.format(path_to_cl_h)
            continue

        with open(path_to_cl_h) as f:
            for line in f.readlines():
                if len(line.strip()) == 0:
                    continue

                if is_excluded_in_patterns(line, EXCLUDE_CODE_PATTERN):
                    continue

                m = success_pattern.match(line.strip()) # special case

                if not m:
                    m = handle_pattern.match(line.strip())

                if m:
                    string = m.group(1)
                    code = m.group(2)

                    test_codes.append(code)
                    write_lines.append('\t\tcase {0}: return "{1}";\n'.format(code, string))
            pass

    write_lines.append('\t\tdefault: return "CL_UNKNOWN_ERROR";\n') 
    write_lines.append('\t}\n')
    write_lines.append('}\n\n')

    write_lines.append('/*\n')
    write_lines.append(' * check cl error, if not CL_SUCCESS, print to stderr\n')
    write_lines.append(' */\n')
    write_lines.append('int clCheckError(int errorCode) {\n')
    write_lines.append('\tif (errorCode != 0) {\n') 
    write_lines.append('\t\tfprintf(stderr, "%s\\n", clGetErrorString(errorCode));\n')
    write_lines.append('\t}\n')
    write_lines.append('\treturn errorCode;\n')
    write_lines.append('}\n\n')
    write_lines.append('#endif /* __CL_EXT__*/\n')

    with open('clext.h', 'w+') as f:
        f.writelines(write_lines)
    print 'Create helper function in file clext.h'

    test_code_lines = []
    test_code_lines.append('\n\n#include "clext.h"\n')
    test_code_lines.append('int main() {\n')
    test_code_lines.append('\tconst int codes[] = { \n')
    test_code_lines.append('\t\t{0}\n'.format(','.join(test_codes)))
    test_code_lines.append('\t};\n')
    test_code_lines.append('\tfor (int i = 0; i < sizeof(codes)/sizeof(int); i++) {\n')
    test_code_lines.append('\t\tclCheckError(codes[i]);\n')
    test_code_lines.append('\t}\n')
    test_code_lines.append('\treturn 0;\n')
    test_code_lines.append('}\n\n\n')

    with open('clext_test.c', 'w+') as f:
        f.writelines(test_code_lines)

    command = 'cc -o clext_test clext_test.c && ./clext_test && echo "test done"'
    os.system(command)
    os.remove('clext_test')
    os.remove('clext_test.c')

if __name__ == "__main__":
    main()
