#!/bin/bash
#
# Linux bash script to print stl or gcode to an ender 5 using printrun
#
# depends on : 
#   printcode.py in PrintRun repo located at https://github.com/kliment/Printrun
#   slic3r for Linux. Repo located at https://github.com/slic3r/Slic3r
#   mailx for Linux from mail-util / bsd-mailx via apt install command
#
# define custom variables
email="" # set to your email address of leave to ignore emailing start/stop of print job. Needs mailx installed.
slicepath="/usr/bin/slic3r"
printcorepath="$HOME/store/3D/BatchPrinting/Printrun/printcore.py"
filamentini="$HOME/.Slic3r/filament/MarksPLA.ini"
printcorefolder=`dirname $printcorepath`
linefile=$printcorefolder/line.gcode # location of the gcode to draw out a starting line of filament 
shutdownfile=$printcorefolder/shutdown.gcode # the code to cool-down after a job
baud=115200 #serial speed for your 3D printer

#
if [ $scan ]
then
 # look for creality ender 5 pro on usb port by vendor
 bus=`lsusb -d 1a86:7523 | awk -F' ' '{print $2}'`
 echo "bus=$bus"
 if [ ! $bus ]
 then
	echo "no usb found!"
	exit 0
 fi
 # find which bus number it is on
 n=$(echo $bus | sed 's/^0*//')
 echo "bus n=$n"
 devfile="/dev/ttyUSB$n"

else
	devfile="/dev/ttyUSB0"
fi


if [ ! -e "$devfile" ]
then
	echo "missing $devfile. Check printer is powered and connected."
	exit 0
fi

if [ ! -f "$printcorepath" ]
then
	echo "missing $printcorepath"
	exit 0
fi

if [ ! -e "$linefile" ]
then
	echo "missing line.gcode"
	exit 0
else
	echo "found line.gcode"
fi

if [ ! -e "$shutdownfile" ]
then
	echo "missing shutdown.gcode"
	exit 0
else	
	echo "found shutdown.gcode"
fi

stlfile=$1
if [ ! -f "$stlfile" ]
then
	echo "missing file: $stlfile"
	exit 1
else
	echo "found $stlfile"
fi

base="${stlfile%%.*}"
ext="${stlfile#*.}"
if [ "$ext" == "stl" ]
then
	echo "stl file supplied."
	echo "slicing.."
	"$slicepath" "$stlfile" --load "$filamentini" --output="$base.gcode"
	if [ -f "$base.gcode" ]
	then
		gcodefile="$base.gcode"
		echo "created gcode file $gcodefile"
	else
		echo "failed to create gcode file"
	fi

elif [ "$ext" == "gcode" ]
then
	echo "gcode already supplied so no slicing needed."
	gcodefile=$1
fi

if [ $email != "" && `which mailx` ]
then
    echo "start of printing of $gcodefile" | mailx -s "3D Printing" $email
fi

echo "printing run line code..."
$printcorepath --baud=$baud $devfile "$linefile"

echo "printing $gcodefile .."
$printcorepath --baud=$baud $devfile "$gcodefile"

echo "printing shutdown.gcode .."
$printcorepath --baud=$baud $devfile "$shutdownfile"

if [ $email != "" && `which mailx`]
then
    echo "end of printing of $gcodefile" | mailx -s "3D Printing" $email
fi
echo "done"
# && pm-suspend &
#echo $! > $HOME/printrunpid.file
