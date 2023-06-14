M107
;M104 S200 ; set temperature
G28 ; home all axes
G1 Z5 F5000 ; lift nozzle

; Filament gcode

;M109 S200 ; set temperature and wait for it to be reached
'M140 S70 ; set bed temp
