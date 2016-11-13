#!/bin/sh

"""":
if which python >/dev/null;then
  exec python "$0" "$@"
else
  echo "${0##*/}: Python not found. Please install python." >&2
  exit 1
fi
"""

__doc__ = """
Demnostrate how to mix Python and shell script.
"""

import sys
print "Hello world!"
print "This is python", sys.version
print "This is my argument vector:", sys.argv
print "This is my doc string:", __doc__
sys.exit(0)
