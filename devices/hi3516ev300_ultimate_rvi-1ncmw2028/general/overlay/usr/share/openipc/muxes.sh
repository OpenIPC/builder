#!/bin/sh

### set off white led ###
gpio clear 72
gpio clear 24

# pwm light control
#devmem 0x100c009c 32 0x1 # pwm 2
#devmem 0x100c00a0 32 0x1 # pwm 3

# gpios
#devmem 0x100c007c 32 0x1000 # gpio 0-6 df -> vd_fz
#devmem 0x112c0074 32 0x1000 # gpio 6-4
#devmem 0x112c0090 32 0x1000 # gpio 8-2
#devmem 0x112c0094 32 0x1000 # gpio 8-3
#devmem 0x112c0040 32 0x100  # gpio 5-0 green led (flash with use wifi connection and not flash for wired)

# after sensor init # (??)
#devmem 0x120100f0 32 0x19
