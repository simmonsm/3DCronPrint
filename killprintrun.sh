#!/bin/bash
# find the process that is using a gcode file and kill it
# assumes enough privilege to send a -9 signal to the process

pid=$(ps -aux | grep -i gcode | grep -v grep |  awk '{print $2}')
if [ $pid ]
then
	echo "sending kill signal to pid $pid"
	kill -9 $pid 
else
	echo "no process found"
fi

