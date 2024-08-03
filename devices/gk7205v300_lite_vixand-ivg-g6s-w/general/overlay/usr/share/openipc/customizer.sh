#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7205v300_lite_vixand-ivg-g6s-w-nor.tgz'
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm603x-gk7205v300-xm-g6s
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# Set majestic settings
#
cli -s .nightMode.irCutPin1 11
cli -s .nightMode.irCutPin2 10
#cli -s .nightMode.backlightPin 14
#cli -s .nightMode.lightMonitor true
#cli -s .nightMode.minThreshold 2000
#cli -s .nightMode.maxThreshold 14000
#cli -s .audio.speakerPin 55
cli -s .video0.codec h264

exit 0
