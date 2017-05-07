#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import getopt
import time

def show_usage():
  print 'A simple script to generate jekyll post template\n'
  print '\tUsage: ', sys.argv[0], '[options]\n'
  print '\t-h|--help show this help'
  print '\t-v|--verbose verbose mode'
  print '\t-t|--title specify the title of your blog, e.g \'My blog title\''
  print '\t-c|--categories specify the categories of your blog'
  print '\t-o|--output specify output file name, will write to a default file name if not specify, - stand for stdout\n'
  sys.exit(0)

def error_action():
  """TODO: Docstring for error_action.
  :returns: TODO

  """
  print 'Error happened\n'
  sys.exit(0)

d = {}
d['-t'] = ''
d['--title'] = ''
d['-c'] = ''
d['--categories'] = ''
d['-v'] = 0
d['--verbose'] = 0
d['-o'] = ''
d['--output'] = ''

verbose = False
title = ''
categories = ''

def main():
  try:
    # Short option syntax: "hv:"
    # Long option syntax: "help" or "verbose="
	opts, args = getopt.getopt(sys.argv[1:], "hv:t:c:o:", ['help', 'title=', 'categories=', 'verbose=', 'output='])
  except getopt.GetoptError, err:
    # Print debug info
    show_usage()

  for option, argument in opts:
    if option in ("-h", "--help"):
      show_usage()
      return
    elif option in d.keys():
      d[option] = argument
    else:
      show_usage()

  if int(d.get('-v')) == 1 or int(d.get('--verbose')) == 1:
    verbose = True
  else:
    verbose = False
  
  if len(d.get('-t')) > 0:
    title = d.get('-t')
  
  if len(d.get('--title')) > 0:
    title = d.get('--title')

  if len(d.get('-c')) > 0:
    categories = d.get('-c')

  if len(d.get('--categories')) > 0:
    categories = d.get('--categories')

  if not 'title' in locals() or not 'categories' in locals():
    show_usage()

  content = '---\nlayout: post\ntitle: {0}\ndate: {1}\ncategories: {2}\n---\n'.format(title, \
      time.strftime('%F %T %z', time.gmtime()), categories)
  filename = time.strftime('%F', time.localtime()) + '-' + title.lower().replace(' ', '-') + '.markdown'

  if len(d.get('--output')) > 0 or len(d.get('-o')) > 0:
	  if d.get('--output') == '-' or d.get('-o') == '-':
		  print filename
		  sys.stdout.write(content)
		  return
	  else:
		  if len(d.get('--output')) > 0:
			  filename = d.get('--output')

		  if len(d.get('-o')) > 0:
			  filename = d.get('-o')


  f = open(filename, 'w+')
  f.write(content)
  f.flush()
  f.close()

if __name__ == "__main__":
  main()
