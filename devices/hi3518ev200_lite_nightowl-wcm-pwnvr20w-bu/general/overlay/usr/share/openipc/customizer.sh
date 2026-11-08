#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_lite_nightowl-wcm-pwnvr20w-bu-nor.tgz'
#
#
# Sensor: SC2135, parallel (DVP), 1080p.
#
fw_setenv sensor sc2135
#
#
# IR-cut: a 150 ms pulse on 65 takes the filter out (night), on 64 puts it back
# (day). The stock Majestic config has these the other way round.
#
cli -s .nightMode.irCutPin1 65
cli -s .nightMode.irCutPin2 64
#
# IR LED ring on 63, active high (muxes.sh makes the pad a GPIO).
#
cli -s .nightMode.backlightPin 63
#
# Light sensor: a photoresistor on SAR ADC channel 0 (outdoor daylight ~11,
# room light 244 of 255), which this Majestic cannot read. Read as a logic
# input on the same pad (62, muxed by muxes.sh) it is 0 in daylight and 1 in
# the dark, and Majestic needs it inverted. It outranks switchBy.
#
cli -s .nightMode.lightMonitor true
cli -s .nightMode.lightSensorPin 62
cli -s .nightMode.lightSensorInvert true
#
#
# Speaker amp enable on 37, active high. Majestic's default, 51, is the
# stock (unfitted) reset-key input.
#
cli -s .audio.speakerPin 37
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188eu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
