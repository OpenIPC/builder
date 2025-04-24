#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_lite_tp-link-tapo-tc70-v3-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .audio.speakerPin 63
cli -s .nightMode.backlightPin 49
cli -s .nightMode.irCutPin1 57
cli -s .nightMode.irCutPin2 58
cli -s .nightMode.colorToGray true
cli -s .nightMode.minThreshold 30
cli -s .nightMode.maxThreshold 150
cli -s .video0.fps 20


#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
