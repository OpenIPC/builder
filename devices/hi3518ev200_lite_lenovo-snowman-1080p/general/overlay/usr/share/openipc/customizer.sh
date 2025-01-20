#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_lite_lenovo-snowman-1080p-nor.tgz'
fw_setenv wlandev 'rtl8188eus-hi3518ev200-lenovo'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 33
cli -s .nightMode.irCutSingleInvert true
cli -s .nightMode.backlightPin 50
cli -s .audio.speakerPin 37

#

exit 0
