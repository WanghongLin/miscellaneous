#!/bin/bash

# use ffmpeg -f avfoundation -list_devices true -i "" to get list of devices

# default is rtmp stream

ps -ef |grep [n]ginx |gawk '{print $2}' |xargs kill

./sbin/nginx -c conf/nginx-rtmp.conf

server_path="mytv"

if [ x$1 == "xhls" ];then
	server_path="hls/stream" # http://localhost:8080/hls/stream.m3u8
elif [ x$1 == "xdash" ];then
	server_path="dash/stream" # http://localhost:8080/dash/stream.mpd
else
	server_path="mytv" # rmtp://localhost:1935/mytv
fi

ffmpeg \
	-f avfoundation -r 30 -s 320x240 -i default \
	-thread_queue_size 1024 -f avfoundation -audio_device_index 0 -i "" \
	-c:v libx264 -pix_fmt yuv420p -vprofile baseline -c:a aac -ar 44100 -ac 2 \
	-f flv rtmp://localhost:1935/$server_path
