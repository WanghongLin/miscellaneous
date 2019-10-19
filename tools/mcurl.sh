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

slices=$(grep -c processor /proc/cpuinfo)
url=
output=

__ScriptVersion="v0.1.1"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
    echo "Usage :  $0 [options] url

    Options:
    -h|help       Display this message
    -v|version    Display script version
    -s|slice      How many slices the download task will split, default is 20
    -o|output     Specify the output file name, use the guessing file name from url as output file name if not specify this option"

}    # ----------  end of function usage  ----------

#-----------------------------------------------------------------------
#  Handle command line arguments
#-----------------------------------------------------------------------

while getopts ":hv:s:o:" opt
do
    case $opt in
	h|help     )  usage; exit 0   ;;
	v|version  )  echo "Multi tasks downloader for curl, version $__ScriptVersion"; exit 0   ;;
	s|slice    )  slices=$OPTARG ;;
	o|output   )  output=$OPTARG ;;
	* )  echo -e "\n  Option does not exist : $OPTARG\n"
	    usage; exit 1   ;;
    esac    # --- end of case ---
done
shift $(($OPTIND-1))

url=${@: -1}

if ! [[ $url =~ ^http[s]://.*$ ]];then
    printf "\e[31mInvalid URL $url\e[0m\n"
    usage
    exit 1
fi

url_no_query=${url%%\?*}
file_to_save=${url_no_query##*/}

[ x$output != x ] && file_to_save=$output

echo "Download $url to $file_to_save with $slices tasks."

size_in_byte=$(curl -I "$url" 2>/dev/null | sed -n 's/\([Cc]ontent-[Ll]ength:\)\(.*\)/\2/p' | tr -d [[:space:]])

if ! [[ $size_in_byte =~ ^[0-9]+$ ]];then
    printf "\e[31mCould not get content length, make sure your resource have content length response.\e[0m\n"
    exit 1
fi

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
		[ $duration -gt 0 ] && printf "\rCurrent average speed %4d KiB/s" $(($total_kb/$duration))
	fi
	sleep 1
done

echo
