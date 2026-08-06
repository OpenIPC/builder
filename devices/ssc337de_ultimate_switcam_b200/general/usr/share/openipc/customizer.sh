#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc337de_ultimate_switcam_b200-nand.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .image.mirror false
cli -s .image.flip false
cli -s .nightMode.irCutPin1 13
cli -s .nightMode.irCutPin2 12
cli -s .nightMode.backlightPin 52
cli -s .nightMode.colorToGray true
cli -s .audio.enabled true
cli -s .audio.codec aac
cli -s .audio.srate 48000
cli -s .audio.inputChannel 1
#

exit 0
