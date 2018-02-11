#!/bin/bash
# show progress bar for adb push or pull
# Copyright 2017 Wanghong Lin 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# 	http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 

function usage()
{
	echo "$0 source destination"
	exit 1
}

function progressbar()
{
	bar="=================================================="
	barlength=${#bar}
	n=$(($1*barlength/100))
	printf "\r[%-${barlength}s] %d%%" "${bar:0:n}" "$1"
	# echo -ne "\b$1"
}

export -f progressbar

[[ $# < 2 ]] && usage

SRC=$1
DST=$2

[ ! -f $SRC ] && { \
	echo "source file not found"; \
	exit 2; \
}

which adb >/dev/null 2>&1 || { \
	echo "adb doesn't exist in your path"; \
	exit 3; \
}

SIZE=$(ls -l $SRC | awk '{print $5}')
ADB_TRACE=adb adb push $SRC $DST 2>&1 \
	| sed -n '/DATA/p' \
	| awk -v T=$SIZE 'BEGIN{FS="[=:]"}{t+=$7;system("progressbar " sprintf("%d\n", t/T*100))}'

echo 
