#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc377_lite_tp-link-tapo-c120-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 81
cli -s .nightMode.irCutSingleInvert true
cli -s .nightMode.backlightPin 14
cli -s .nightMode.colorToGray true
cli -s .audio.codec opus
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-tapo-c120
fw_setenv sensor sc430ai
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
