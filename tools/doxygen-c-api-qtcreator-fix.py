#!/usr/bin/env python
# -*- coding: utf-8 -*-

# A simple script to adapter doxygen c API qch file to QtCreator
# Copyright 2017 yourname
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
# 

from bs4 import BeautifulSoup
from bs4 import Comment
import os
import re
import argparse

def main(qhp_file):
  """TODO: Docstring for main.
  :returns: TODO

  """
  src_file = open(qhp_file)
  dst_file = open(os.path.dirname(src_file.name) + os.path.sep + 'index-fix.qhp', 'w')
  soup = BeautifulSoup(src_file, 'xml')
  keywords = soup.findAll('keyword')
  for keyword in keywords:
    kid = keyword['id']
    m = re.match(r'lav.*::(.*)$', kid)
    if m:
      keyword['id'] = m.group(1)
    pass

  # DO NOT use soup.prettify
  # qhelpgenerator CAN NOT recognize the format
  dst_file.write(str(soup))

  # see https://github.com/mmmarcos/doxygen2qtcreator/blob/master/doxygen2qtcreator.py
  # popup tooltips for function call MUST have the format
  # <!-- $$$function_name[overload1]$$$ -->
  # <div class='memdoc'>
  # <p>Only the first p tag can be show in popup tooltips/hover documentation</p>
  # <!-- @@@function_name -->
  # ...
  # ...
  # </div>
  files = soup.find_all('file')
  common_dir = os.path.dirname(src_file.name);
  for f in files:
    html_file = open(common_dir + os.path.sep + f.text, 'rw+')
    if html_file:
      html_soup = BeautifulSoup(html_file, 'html.parser')
      memitems = html_soup.find_all('div', {'class': 'memitem'})
      should_write_back_to_file = False
      if memitems:
        for item in memitems:
          memname = item.find('td', {'class': 'memname'})
          memdoc = item.find('div', {'class': 'memdoc'})
          if memdoc and memname > 0:
            html_text = memname.get_text()
            names = html_text.strip(' ').split(' ')
            # Only handle function call name
            # ffmpeg av_xxxxx
            # int function_call_name
            if len(names) == 2 and names[1].startswith('av'):
              # TODO:merge multiple <p> tags in memdoc
              # QtCreator only pick the first <p> tag to display in the tooltips
              marker_start = u' $$${0}[overload1]$$$ '.format(names[1])
              marker_end = u' @@@{0} '.format(names[1])
              memdoc.insert_before(Comment(marker_start))
              memdoc.insert_after(Comment(marker_end))
              should_write_back_to_file = True
          pass
    if should_write_back_to_file:
      print 'insert QtCreator style marker for %s' % html_file.name
      html_file.seek(0)
      html_file.write(html_soup.prettify().encode('utf-8'))
    html_file.close()
    pass

  src_file.close()
  dst_file.close()

  print 'Done, /path/to/qhelpgenerator %s -o index.qch' % dst_file.name
  print 'Then, attach index.qch file to your QtCreator'
  print 'Tool -> Options -> Help -> Documentation -> Add'
  pass

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument('qhp_file', help='The full path of your Qt Help Project file')
  args = parser.parse_args()
  if args.qhp_file:
    main(args.qhp_file)
