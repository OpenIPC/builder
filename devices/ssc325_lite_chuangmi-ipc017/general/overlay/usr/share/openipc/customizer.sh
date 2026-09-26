#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc325_lite_chuangmi-ipc017-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 78
cli -s .nightMode.irCutPin2 79
cli -s .nightMode.backlightPin 52
cli -s .nightMode.lightMonitor true
cli -s .nightMode.autoNightGain 8
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev mt7601u-ssc325-chuangmi-ipc017
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
