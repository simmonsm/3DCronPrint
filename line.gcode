M140 S70
M105
M190 S70
M104 S200
M105
M109 S200
M82 ;absolute extrusion mode
M201 X500.00 Y500.00 Z100.00 E5000.00 ;Setup machine max acceleration
M203 X500.00 Y500.00 Z10.00 E50.00 ;Setup machine max feedrate
M204 P500.00 R1000.00 T500.00 ;Setup Print/Retract/Travel acceleration
M205 X8.00 Y8.00 Z0.40 E5.00 ;Setup Jerk
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate

G28 ;Home

G92 E0 ;Reset Extruder
G1 Z2.0 F3000 ;Move Z Axis up
G1 X10.1 Y20 Z0.28 F5000.0 ;Move to start position
G1 X10.1 Y200.0 Z0.28 F1500.0 E15 ;Draw the first line
G1 X10.4 Y200.0 Z0.28 F5000.0 ;Move to side a little
G1 X10.4 Y20 Z0.28 F1500.0 E30 ;Draw the second line
G92 E0 ;Reset Extruder
G1 Z2.0 F3000; Move Z Axis up


; end code====================
;M107
;G91 ;Relative positioning
;G1 E-2 F2700 ;Retract a bit
;G1 E-2 Z0.2 F2400 ;Retract and raise Z
;G1 X5 Y5 F3000 ;Wipe out
;G1 Z10 ;Raise Z more
;G90 ;Absolute positioning

;G28 X0 Y0 ;Present print
;M106 S0 ;Turn-off fan
;M104 S0 ;Turn-off hotend
;M140 S0 ;Turn-off bed

;M84 X Y E ;Disable all steppers but Z

;M82 ;absolute extrusion mode
;M104 S0

