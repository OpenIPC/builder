#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc325_lite_tp-link-tapo-c310-v1-nor.tgz'
#
#
# Set custom majestic settings
#
#cli -s .nightMode.enabled true
#cli -s .nightMode.irCutPin1 78
#cli -s .nightMode.irCutPin2 79
#cli -s .nightMode.backlightPin 52
#cli -s .nightMode.colorToGray true
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8192eu-ssc325-tapo-c310v1
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
