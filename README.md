# 3DCronPrint
Timed 3D printing from Linux via crontab using PrintRun package.

To use cheaper night rate electricity your can print at say 1.30am 
by inserting a line in your crontab like this:

`30 01 15 06 * /pathto/3DCronPrint/print.sh /pathto/myexample.gcode`
