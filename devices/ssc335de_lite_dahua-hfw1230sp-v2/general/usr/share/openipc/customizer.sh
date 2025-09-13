#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc335de_lite_dahua-hfw1230sp-v2-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .image.mirror false
cli -s .image.flip false
cli -s .nightMode.irCutPin1 79
cli -s .nightMode.irCutPin2 78
cli -s .nightMode.backlightPin 52
cli -s .nightMode.colorToGray true
cli -s .audio.inputChannel 1
#

exit 0
