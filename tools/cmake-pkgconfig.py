#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# generate cmake text for pkg-config
#

import argparse
import sys


def do_stuff(name, libs):
    module = name
    for l in libs:
        module += ' '
        module += l
    print '\tpkg_check_modules({})'.format(module)
    print '\tif ({}_FOUND)'.format(name)
    print '\t\tinclude_directories(${{{}_INCLUDE_DIRS}})'.format(name)
    print '\t\tlink_directories(${{{}_LIBRARY_DIRS}})'.format(name)
    print '\t\tlink_libraries(${{{}_LIBRARIES}})'.format(name)
    print '\tendif ({}_FOUND)'.format(name)


def main():
    parser = argparse.ArgumentParser(description='Generate cmake for pkg-config',
                                     epilog='It will help a lot!')
    parser.add_argument('--path', action='append', help='pkg-config path')
    parser.add_argument('--name', required=True, action='append', help='the library name in cmake')
    parser.add_argument('--libs', required=True, nargs='+', action='append', help='a list of libraries')
    args = parser.parse_args()

    if args.name is not None and args.libs is not None and len(args.name) == len(args.libs):

        # print path
        if args.path is not None:
            for p in args.path:
                print 'set(ENV{{PKG_CONFIG_PATH}} "$ENV{{PKG_CONFIG_PATH}}:{}")'.format(p)

        # print header
        print 'include(FindPkgConfig)'
        print 'if (PkgConfig_FOUND)'

        # print the library
        for i in range(len(args.name)):
            do_stuff(args.name[i], args.libs[i])

        # print end tags
        print 'endif (PkgConfig_FOUND)'
    else:
        print 'name and libs should be matched'
        parser.print_help(sys.stdout)
        sys.exit(0)
    pass


if __name__ == '__main__':
    main()
