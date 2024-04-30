#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc335_lite_trassir-tr-w2c1-v2-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 79
cli -s .nightMode.irCutPin2 78
cli -s .nightMode.backlightPin 14
cli -s .nightMode.colorToGray true
cli -s .image.mirror true
cli -s .image.flip true
cli -s .audio.speakerPin 15
cli -s .audio.outputVolume 80
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev mt7601sta-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
