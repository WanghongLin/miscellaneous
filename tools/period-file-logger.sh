#!/bin/bash
# long running command wrapper to output the log to different file for
# a period of time
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
#

# in seconds
logger_update_duration=60

background_pid=
main_cmd=

function update_file_name() {
	trap "update_file_name" USR1 # re-establish

	file_name=$(date +"%Y-%m-%d-%H-%M-%S.log")
	echo "update file name $file_name"

	cat < ./logger > $file_name &
	# after establish the new, check should kill the old
	if [ x$background_pid != x ];then
		echo "will kill the old $background_pid current is $$"
		kill -TERM $background_pid
	fi
	background_pid=$!
}
trap "update_file_name" USR1

function clean() {
	echo "perform clean..."
	kill -TERM $!
	kill -TERM $main_cmd
	rm logger
}
trap "clean" EXIT


# create logger fifo
[ ! -p logger ] && mkfifo logger

# replace with your long time running operation
./long-running-cmd > ./logger &
main_cmd=$!

while true
do 
	kill -USR1 $$
	sleep ${logger_update_duration}
done
