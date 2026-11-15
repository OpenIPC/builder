#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/xm530_lite_misecu-xm-63-ai-50w-nor.tgz'
#
# Set wlan device, its PDN gpio and credentials if need
#
fw_setenv wlandev atbm603x-xm530
fw_setenv wifipdn 96
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# Night mode, as reported in OpenIPC/firmware#2853: IR LEDs on gpio 39, white
# LEDs on gpio 41, IR-cut coils on gpio 1 and 2. The board has no light
# sensor, and which coil majestic should call irCutPin1 is not confirmed yet.
#cli -s .nightMode.backlightPin 39
#cli -s .nightMode.irCutPin1 1
#cli -s .nightMode.irCutPin2 2
#
(sleep 3 ; reboot -f) &

exit 0
