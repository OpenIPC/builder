#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_lite_vstarcam-c8892wip-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.lightMonitor true
cli -s .nightMode.lightSensorPin 62
cli -s .nightMode.lightSensorInvert true
cli -s .nightMode.irCutPin1 65
cli -s .nightMode.irCutPin2 64
cli -s .nightMode.backlightPin 1
cli -s .video0.codec h264
cli -s .video0.fps 30
cli -s .isp.slowShutter disabled
#
# front white led gpio - 0
# reset gpio - ?
#
# Set wlan device and credentials if need
#
fw_setenv wlandev mt7601u-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
