#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# APPIX SC03-W: AK3918EV300L, two SmartSens SC1346 behind one MIPI switch
# (separate lenses, the lower one on the pan/tilt head), 8 MB NOR, AltoBeam
# ATBM603x USB Wi-Fi, pan/tilt steppers on GPIO, IR and white lights,
# speaker, reset button. Its stock firmware is GZhongshi's (OpenIPC/majestic#380).
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ak3918ev300l_lite_appix-sc03w-nor.tgz'
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm603x-ak3918ev300l-appix-sc03w
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set custom majestic settings
#
# The pins the stock firmware's factory_cfg.ini names: IR-cut on 65/66, IR
# LEDs on 10, white light on 9. Majestic pulses irCutPin1 for night and
# irCutPin2 for day, and on this board that is 66 and 65 -- the other way
# round from the stock file's ircut_a/ircut_b order (confirmed on the
# camera, OpenIPC/majestic#380).
cli -s .nightMode.irCutPin1 66
cli -s .nightMode.irCutPin2 65
cli -s .nightMode.backlightPin 10
cli -s .nightMode.whiteLightPin 9
# Automatic day/night, off by default in majestic. On this camera covering
# the lens switches to night and uncovering it back to day.
cli -s .nightMode.lightMonitor true
# The WebUI's pan/tilt pad reads mirror, flip and rotate, and refuses every
# move while one of them is missing.
cli -s .image.mirror false
cli -s .image.flip false
cli -s .image.rotate 0
# Pan/tilt through majestic-af's gpiostep actuator (/ptz, ONVIF, WebUI).
cli -s .ptz.enabled true
cli -s .ptz.actuator gpiostep
fw_setenv ptz_control gpiostep
fw_setenv ptz_caps 'pan tilt'

exit 0
