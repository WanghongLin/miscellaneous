#!/bin/bash
# Remove unused kernel after kernel upgrade and reboot for Ubuntu
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

[[ ! `lsb_release -i` =~ .*Ubuntu.* ]] && {
	echo "Only support Ubuntu Linux distribution"
	exit 0
}

install_kernels=$(dpkg -l |grep "^ii.*linux-image" |awk '{print $2}')
current_release=$(uname -r)

printf "\e[32minstalled kernels:\n"
for k in $install_kernels
do
	printf "\n\t\e[32m$k\e[0m"
done

printf "\n\ncurrent kernel release: \e[32m\n\n\t$current_release\e[0m\n"

will_remove=()

for v in $install_kernels
do
	if [[ $v =~ .*[0-9].* ]];then
		vv=${v/-generic/}
		vvv=${vv##linux-image-}
		if [[ $current_release =~ .*$vvv.* ]];then
			:
		else
			will_remove+=($vvv)
		fi
	fi
done

printf "\n\n\e[31mwill remove:\n\e[0m\n"
for k in $will_remove
do
	printf "\t$k\n"
done

read -p "Input yes/no to confirm? " confirm
if [[ $confirm == yes ]];then
	# apt remove
	for k in $will_remove
	do
		sudo apt-get -y remove linux-{image,headers,modules}-$k{,-generic}
	done
fi
