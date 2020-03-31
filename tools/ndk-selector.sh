#!/bin/bash
#
# A help script to select different standalone ndk for different 
# architectures
# Copyright 2020 Wanghong Lin
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
# suppose ndk tools are created under $HOME/ndk from make_standalone_toolchain.py
#

function ndk-selector()
{
    declare -a maps
    i=0
    for d in `ls $HOME/ndk`
    do
	maps[$i]=$d
	let i=i+1
    done
    echo "Avaliable toolchains"
    for ((j=0; j<$i; j++))
    do
	echo -e "\t[$j] ${maps[$j]}"
    done

    local choice=$i
    until [[ $choice -ge 0 && $choice -lt $i ]]; do
	read -p 'Select which toolchains? ' choice
    done

    printf "\033[0;32mSelect ${maps[$choice]} as the current toolchain\033[0m\n"
    local bin_path=$HOME/ndk/${maps[$choice]}/bin
    export PATH=${PATH//$HOME\/ndk\/*/}:${bin_path}
    for f in $(ls ${bin_path}/*)
    do
	if [[ $f =~ .*gcc$ ]];then
	    export CC=$f
	fi
    done
    local api=14
    if [[ ${maps[$choice]} =~ .*64 ]]; then
	api=21
    fi
    export CFLAGS="-D__ANDROID_API__=$api -fPIE"
    export LDFLAGS='-pie'
    printf "\n\033[0;31mWith environment settings\033[0m\n"
    printf "\tPATH\t = ${PATH}\n"
    printf "\tCC\t = $CC\n"
    printf "\tCFLAGS\t = $CFLAGS\n"
    printf "\tLDFLAGS\t = $LDFLAGS\n"
    printf "\n"
}
