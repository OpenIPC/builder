#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc325de_lite_imou-c22ep-s2-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 13
cli -s .nightMode.irCutPin2 12
cli -s .nightMode.backlightPin 52
cli -s .nightMode.colorToGray true
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-ssc325de-imou-c22ep-s2
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0