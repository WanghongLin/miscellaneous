#!/bin/bash
# ADB screenshot for Linux or macOS
# Copyright 2019 Wanghong Lin 
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
# Just source this file
# 
# $ source adb-screenshot.sh
#
# Use adb_screenshot to obtain screenshot only support portrait mode via screencap
# Use adb_screenshot_v2 to support portrait/landscape mode via screenrecord
# 
# Imagemagick and ffmpeg should installed for adb_screenshot_v2
# to extract image from video stream
#
# Temporary file get deleted after screenshot
# The final picture will be opened with your default picture viewer
#

function view_cmd() 
{
    local _view_cmd=
    case $OSTYPE in
	linux*) _view_cmd="xdg-open %s" ;;
	darwin*) _view_cmd="open %s" ;;
	*) ;;
    esac
    echo "$_view_cmd"
}

function adb_screenshot() 
{
    local f=Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png
    adb shell screencap -p > $f && \
	eval `printf "$(view_cmd)" $f`
}

#the following method can avoid image stretching if target device in landscape mode
function adb_screenshot_v2() 
{
    local _b=$(basename `mktemp`).mp4 #basename
    local _f=/data/local/tmp/$_b #filename on device
    local _o=Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png #filename on host
    adb shell screenrecord --time-limit 1 $_f && \
	adb pull $_f && adb shell rm $_f && \
	convert ${_b}[0] $_o && rm -v $_b && \
	eval `printf "$(view_cmd)" $_o`
}
