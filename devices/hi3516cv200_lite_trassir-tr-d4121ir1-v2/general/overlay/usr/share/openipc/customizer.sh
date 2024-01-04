#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516cv200_lite_trassir-tr-d4121ir1-v2-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .system.staticDir /var/www/majestic
cli -s .nightMode.enabled true
#cli -s .nightMode.irSensorPin ??
#cli -s .nightMode.irSensorPinInvert true
#cli -s .nightMode.irCutPin1 ??
#cli -s .nightMode.irCutPin2 ??
#cli -s .nightMode.backlightPin ??
cli -s .video0.codec h264
cli -s .video0.fps 30
cli -s .isp.slowShutter disabled
#
# front white led gpio - 0
# reset gpio - ?
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev mt7601u-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
