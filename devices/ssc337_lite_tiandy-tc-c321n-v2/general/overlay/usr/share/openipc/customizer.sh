#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc337_lite_tiandy-tc-c321n-v2-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 78
cli -s .nightMode.irCutPin2 79
cli -s .nightMode.backlightPin 37
cli -s .audio.enabled true
cli -s .audio.volume 50
#
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev rtl8188fu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
