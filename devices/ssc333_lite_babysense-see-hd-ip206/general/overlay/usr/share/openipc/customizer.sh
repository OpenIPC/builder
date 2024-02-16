#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc333_lite_babysense-see-hd-ip206-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.enabled true
cli -s .nightMode.irCutPin1 79
cli -s .nightMode.irCutPin2 78
cli -s .nightMode.backlightPin 61
cli -s .audio.speakerPin 15
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-babysense-see-hd-ip206
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
