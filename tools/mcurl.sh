#!/bin/bash
# 
# Simulate multiple threads downloading by forking many process
# Copyright 2016 Wanghong Lin 
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
# 
# Changelog
# v0.1        initial version
# v0.1.1      add output option

slices=20
url=
output=

__ScriptVersion="v0.1.1"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	echo "Usage :  $0 [options]

    Options:
    -h|help       Display this message
    -v|version    Display script version
    -u|url        The URL to download
    -s|slice      How many slices the download task will split, default is 20
    -o|output     Specify the output file name, use the guessing file name from url as output file name if not specify this option"

}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts ":hvu:s:o:" opt
do
  case $opt in

	h|help     )  usage; exit 0   ;;

	v|version  )  echo "Multi tasks downloader for curl, version $__ScriptVersion"; exit 0   ;;

    u|url      )  url=$OPTARG ;;

    s|slice    )  slices=$OPTARG ;;

	o|output   )  output=$OPTARG ;;

	* )  echo -e "\n  Option does not exist : $OPTARG\n"
		  usage; exit 1   ;;

  esac    # --- end of case ---
done
shift $(($OPTIND-1))

[ -z $url ] && { usage; exit 1; }

path=${url##*/}
file_to_save=${path%\?*}

[ x$output != x ] && file_to_save=$output

echo Download $url to $file_to_save with $slices tasks.

size_in_byte=$(curl -I "$url" 2>/dev/null | sed -n 's/\(Content-Length:\)\(.*\)/\2/p' | tr -d [[:space:]])
size_per_slice=$(($size_in_byte/$slices))
let size_per_slice=${size_per_slice}+1  # avoid rounding issue

total_slice=${slices}
finished_slice=0
is_finished=0
function callback()
{
	subp=$(pgrep -P $$ | wc -l)
	if [  $subp -eq 1 ];then
		for s in `seq $total_slice`
		do
			cat $$.$s >> "${file_to_save}"
			rm $$.$s
		done
		is_finished=1
	fi
}

function run()
{
	curl -r $2-$3 $url -o $1 2>/dev/null && kill -n 10 $$ &
}

trap callback 10

start_time=$(date +%s)
for s in `seq $total_slice`
do
	begin=$((($s-1)*${size_per_slice}))
	if [ $begin -ne 0 ];then
		begin=$((begin+=1))
	fi
	end=$(($s*$size_per_slice))
	if [ $end -gt $size_in_byte ];then
		end=
	fi
	run $$.$s $begin $end
done

until [ $is_finished -eq 1 ]
do
	if [ -f $$.1 ];then
		total_kb=$(du -b $$.* | awk '{t+=$1}END{printf "%d", t/1024}')
		duration=$((`date +%s`-$start_time))
		[ $duration -gt 0 ] && printf "\rCurrent average speed %4dKiB/s" $(($total_kb/$duration))
	fi
	sleep 1
done
