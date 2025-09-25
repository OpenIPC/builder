#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7205v210_lite_vixand-ivg-g3s-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
#cli -s .audio.speakerPin 55
cli -s .nightMode.irCutPin1 9
cli -s .nightMode.irCutPin2 8
cli -s .nightMode.backlightPin 16
#cli -s .nightMode.lightMonitor true
cli -s .nightMode.minThreshold 2000
cli -s .nightMode.maxThreshold 14000
#
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev unknown
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
fw_setenv soc gk7205v210
#
adduser viewer -s /bin/false -D -H
echo viewer:123456 | chpasswd
#

exit 0
