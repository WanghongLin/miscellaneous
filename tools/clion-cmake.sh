#!/bin/bash
#
# Simple script to generate cmake file for intellij clion code navigate
#
# Copyright 2018 Wanghong Lin
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

if [[ $# -lt 1 ]];then
	printf "Usage: $0 source-dirs"
	printf "\n\ne.g in ffmpeg, add doc/examples and fftools and all the directories started with lib*\n"
	printf "\n"
	printf "\t\$$0 doc/examples fftools lib*\n"
	printf "\n"
	exit 0
fi

dir=$(pwd)
name=$(basename ${dir})
out_file=${name}.cmake

echo "# This file is generated from $0 at $(date)" > ${out_file}
echo >> ${out_file}
echo "project($name)" >> ${out_file}
echo >> ${out_file}
echo "include_directories($dir)" >> ${out_file}
echo >> ${out_file}

for d in "$@"
do
	library_name=$(echo $d | sed 's/[\/ ]/_/g')
	src_dir=
	if [[ "$d" =~ /.* ]];then
		src_dir=$d
	else
		src_dir=${dir}/${d}
	fi
	echo "aux_source_directory(\"${src_dir}\" srcs_${library_name})" >> ${out_file}
	echo 'add_library('"${library_name}"' MODULE ${srcs_'"${library_name}"'})' >> ${out_file}
	echo >> ${out_file}
done


[[ -h CMakeLists.txt ]] && rm CMakeLists.txt
ln -vs ${out_file} CMakeLists.txt

echo "You can add this project to your clion project with following command"
echo
echo -e "\tadd_subdirectory($dir $name)"
echo
echo "Done"
echo
