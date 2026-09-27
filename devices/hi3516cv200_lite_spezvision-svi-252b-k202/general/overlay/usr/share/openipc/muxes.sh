#!/bin/sh
#
# SpezVision SVI-252B K202 board pinmux preset.
# S30customizer runs this script on every boot.
#
# Stock Sofia configures GPIO3_0 as the digital daylight sensor input by
# selecting mux function 0 at 0x200f0034. Keep this board contract outside
# Majestic so another streamer/runtime sees the same hardware setup.
#

devmem 0x200f0034 32 0
