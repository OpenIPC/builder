#!/bin/sh

### set leds power off ###
gpio set 10
gpio set 25

### sd card power en ###
devmem 0x100c0058 32 0
gpio set 38
