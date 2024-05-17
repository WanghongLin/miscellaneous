#!/bin/bash
# a simple script to compare two file size with formated output
# 
# truncate -s 100M 1.txt
# truncate -s 130M 2.txt
# bash compare.sh 1.txt 2.txt
# ----------------------------
# |  1.txt  |  2.txt  |delta|
# ----------------------------
# |104857600|136314880|+30Mi|
# ----------------------------
#


function usage()
{
	echo -e "\e[1;31mUsage: $0 file1 file2\e[0m"
	exit 1
}

function gen_hyphen()
{
	eval echo {0..$1} |sed 's/ /-/g;s/[0-9]//g'
}

function gen_space()
{
	eval echo {0..$1} |sed 's/[0-9]//g'
}

if [[ ! $# -eq 2 ]];then
	usage
fi

if [[ ! -f $1 || ! -f $2 ]];then
	echo -e "\e[1;31m$1 or $2 must be a regular file\e[0m"
	exit 2
fi


file_size1=$(stat -c%s $1)
file_size2=$(stat -c%s $2)
f1_len=${#file_size1}
f2_len=${#file_size2}
delta=$(($file_size2-$file_size1))

base_name1=" ${1##*/} " # two more extra space
base_name2=" ${2##*/} "
b1_len=${#base_name1}
b2_len=${#base_name2}

# always assume file name text is longer than its size text
# if not, we pad it with some spaces
if [[ $b1_len -lt $f1_len ]];then
	b1_pad=$((($f1_len-$b1_len)/2))
	base_name1="$(gen_space $b1_pad)${base_name1}$(gen_space $b1_pad)"
	b1_len=${#base_name1}
fi

if [[ $b2_len -lt $f2_len ]];then
	b2_pad=$((($f2_len-$b2_len)/2))
	base_name2="$(gen_space $b2_pad)${base_name2}$(gen_space $b2_pad)"
	b2_len=${#base_name2}
fi

len=$(($b1_len+$b2_len))
horizontal_line="----------$(gen_hyphen $len)"

file_size1_prefix_len=$((($b1_len-${#file_size1})/2))
file_size1_suffix_len=$(($b1_len-$file_size1_prefix_len-${#file_size1}))


file_size2_prefix_len=$((($b2_len-${#file_size2})/2))
file_size2_suffix_len=$(($b2_len-$file_size2_prefix_len-${#file_size2}))

sign="+"
color="\e[1;31m"
if [[ $delta -lt 0 ]];then
	sign="-"
	delta=$((-$delta))
	color="\e[1;32m"
fi

echo $horizontal_line
echo "|$base_name1|$base_name2|delta|"
echo $horizontal_line
echo -e "|$(gen_space $file_size1_prefix_len)$file_size1$(gen_space $file_size1_prefix_len)|$(gen_space $file_size2_prefix_len)$file_size2$(gen_space $file_size2_suffix_len)|${color}${sign}$(numfmt --to=iec-i $delta)\e[0m|"
echo $horizontal_line
