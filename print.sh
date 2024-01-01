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
email="mark@ludshottcomputing.com" # set to your email address of leave to ignore emailing start/stop of print job. Needs mailx installed.
slicepath="/usr/bin/slic3r"
printcorepath="$HOME/store/3D/Printrun/printcore.py"
filamentini="$HOME/.Slic3r/filament/MarksPLA.ini"
printcorefolder=`dirname $printcorepath`
lockfile="$printcorefolder/print_bed_occupied.tmp"
SOURCE=${BASH_SOURCE[0]}
while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
  SOURCE=$(readlink "$SOURCE")
  [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
scriptfolder=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
echo "$scriptfolder"
shutdownfile="$scriptfolder/shutdown.gcode" # the code to cool-down after a job
resetfile="$scriptfolder/reset.gcode" # code to reset printer
baud=115200 #serial speed for your 3D printer
mx=$(which mailx)

# look for creality ender 5 pro on usb port by vendor 
# can use lsusb to find the vendor id and device id
# see also https://www.linux-usb.org/usb.ids for list
# for this case 1a86:7523 is the QinHeng Electronics CH340 serial converter
serialvendorstring="1a86:7523" # TODO: change to your printers equivalent!

stlfile="" # pass in stlfile as 1st arg
devfile="" # can pass in /dev/ttyUSB0 as 2nd arg
if [ $# -eq 0 ]
then
  echo "usage: $0 stlfile|gcodefile [devicefile]"
  exit 1
fi

if [ $# -gt 0 ]
then
	stlfile=$1
fi
echo "stlfile=$stlfile"
if [ $# -gt 1 ]
then
	devfile=$2
fi
echo "devfile=$devfile"

#
if [ $scan ]
then
 bus=`lsusb -d $serialvendorstring | awk -F' ' '{print $2}'`
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
	if [ "$devfile" = "" ] # so not given as a param
	then
		devfile="/dev/ttyUSB0"
	fi
fi


if [ ! -e "$devfile" ]
then
	echo "missing device: $devfile. Check printer is powered and connected."
	exit 0
fi
echo "using device: $devfile"

if [ ! -f "$printcorepath" ]
then
	echo "missing $printcorepath"
	exit 0
fi


if [ ! -e "$shutdownfile" ]
then
	echo "missing $shutdownfile"
	exit 0
else	
	echo "found $shutdownfile"
fi

if [ ! -f "$stlfile" ]
then
	echo "missing file: $stlfile"
	exit 1
else
	echo "found $stlfile"
fi

base="${stlfile%.*}"
echo "base=$base"
ext="${stlfile##*.}"
echo "ext=$ext"
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

if [ "$mx" != "" ]
then
	if [ "$email" != "" ]
	then
    		echo "start of printing of $gcodefile" | $mx -s "3D Printing" $email
	fi
fi

trap ctrl_c INT

function ctrl_c() {
        echo "** Trapped CTRL-C"
	echo "attempting printer reset..."
	$printcorepath -s --baud=$baud $devfile "$resetfile"
	
	if [ "$email" != "" ]
	then
		echo "interupted printing of $gcodefile" | $mx -s "3D Printing" $email
	fi

	echo "exiting"
	exit
}

# ensure we don't attempt to print again whilst a model is on the bed
if [ -f $lockfile ] 
then
	echo "A lockfile $lockfile was found. If bed is clear remove that file. Aborting"
	exit
fi

touch $lockfile

# the cura produced gcode contains line drawing but needed if we slice stl
# with slic3r
if [ $ext == "stl" ]
then
	echo "printing run line code..."
	$printcorepath -s --baud=$baud $devfile "$linefile"
fi

echo "printing $gcodefile .."
$printcorepath -s --baud=$baud $devfile "$gcodefile"

echo "printing shutdown.gcode .."
$printcorepath -s --baud=$baud $devfile "$shutdownfile"

if [ "$mx" != "" ]
then
	if [ "$email" != "" ]
	then
    		echo "end of printing of $gcodefile" | $mx -s "3D Printing" $email
	fi
fi

echo "done"
# && pm-suspend &
#echo $! > $HOME/printrunpid.file
