# 3DCronPrint
Timed 3D printing via crontab using PrintRun
to use cheaper night rate electricity your can print at say 1.30am 
by inserting a line in your crontab like this:
`30 01 15 06 * /pathto/3DCronPrint/print.sh /pathto/myexample.gcode`
