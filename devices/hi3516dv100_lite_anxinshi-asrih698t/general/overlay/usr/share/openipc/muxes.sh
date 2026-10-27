#!/bin/sh
#
# Anxinshi ASRIH698T-020-20X pinmux preset; S30customizer runs it on every
# boot, before majestic opens the port.
#
# The pan/tilt MCU sits behind an RS-485 transceiver on UART1. The stock
# firmware muxes UART1 RXD/TXD and keeps the UART1_RTSN ball as GPIO9_2,
# driven as the transceiver's direction pin (Hi3516A/D datasheet table 2-48;
# OpenIPC/firmware#2385). GPIO9_2 resets low, which is receive, so nothing
# majestic sends would reach the bus. Pan/tilt frames need no reply, so the
# pin is held high.
#

devmem 0x200f0078 32 0
devmem 0x200f007c 32 1
devmem 0x200f0084 32 1

dir=$(devmem 0x201d0400)
devmem 0x201d0400 32 $((dir | 0x4))
devmem 0x201d0010 32 0x4

### settings an earlier version of this profile wrote ###
# customizer.sh runs once, so a dome set up before majestic-af could drive the
# lens and the base together kept ptz_caps 'pan tilt' and a majestic.yaml that
# names neither the lens nor the head. That exact value is the tell: only that
# version wrote it, and clearing it makes this run once. The lens and head are
# set only where the owner has not named an actuator or a head of their own.
if [ "$(fw_printenv -n ptz_caps 2>/dev/null)" = "pan tilt" ]; then
	fw_setenv ptz_caps
	act=$(cli -g .ptz.actuator 2>/dev/null)
	if [ -z "$(cli -g .ptz.head 2>/dev/null)" ] && { [ -z "$act" ] || [ "$act" = "pelco-d" ]; }; then
		cli -s .ptz.actuator ms41908
		cli -s .ptz.head pelco-d
	fi
fi

### this dome's PTZ settings, wherever majestic.yaml has none ###
# customizer.sh runs once, on a camera with no settings; an upgrade that keeps
# them, or a reset of majestic.yaml alone, never runs it again, and leaves the
# dome on the environment's base with no lens (OpenIPC/firmware#2385). So each
# boot, before majestic starts, a setting this dome needs is written only where
# the file has no value for it: whatever the owner has set stays.
#
# The lens, where no actuator is named -- the environment's default would make
# the base the lens, and then refuse it as the head (the dome of #2385 came up
# so). The head, where none is named and the lens is this one. An owner who
# names pelco-d as the actuator, for the base alone, keeps it.
act=$(cli -g .ptz.actuator 2>/dev/null)
if [ -z "$act" ]; then
	cli -s .ptz.actuator ms41908
	act=ms41908
fi
if [ "$act" = ms41908 ] && [ -z "$(cli -g .ptz.head 2>/dev/null)" ]; then
	cli -s .ptz.head pelco-d
fi
# The 20x lens, measured on the dome: zoom 3320 steps, 1-20x, the home stop at
# tele; focus travel not measured exactly, 3000 covers it. No working
# photo-interrupter, so it is homed into its end stops at start. The base is
# mounted the other way from the sensor, so both directions are inverted.
for kv in lensZoomSteps=3320 lensFocusSteps=3000 lensZoomMax=20 lensHome=true \
	panInvert=true tiltInvert=true; do
	[ -n "$(cli -g .ptz.${kv%%=*} 2>/dev/null)" ] || cli -s .ptz.${kv%%=*} ${kv#*=}
done
