#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7202v300_lite_xg521-nor.tgz'
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 15
cli -s .nightMode.irCutPin2 14
cli -s .nightMode.colorToGray false
cli -s .nightMode.backlightPin 54
cli -s .video0.codec h264
cli -s .audio.speakerPin 4
#
# Set wlan device and credentials if need
#
fw_setenv wlandev ec800e-gk7202v300-xg521

exit 0
