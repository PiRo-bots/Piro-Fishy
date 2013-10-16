#!/bin/sh -
node server.js &
raspistill -w 320 -h 240 -q 65 -o /tmp/stream/pic.jpg -tl 50 -t 9999999 -th 0:0:0 &
pushd ../../libs/mjpg-streamer/mjpg-streamer
pwd
LD_LIBRARY_PATH=./ ./mjpg_streamer -i "input_file.so -f /tmp/stream" -o "output_http.so -w ./www" &
popd
#LD_LIBRARY_PATH=../../libs/mjpg-streamer/mjpg-streamer ../../libs/mjpg-streamer/mjpg-streamer/mjpg_streamer -i "input_file.so -f /tmp/stream" -o  #"output_http.so -w ./www" &
