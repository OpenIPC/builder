#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_ultimate_gcraftsman-gca50-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .system.plugins true
cli -s .nightMode.enabled true
cli -s .nightMode.irCutPin1 58
cli -s .nightMode.irCutPin2 57
cli -s .nightMode.backlightPin 50
cli -s .video0.codec h264
#
exit 0
