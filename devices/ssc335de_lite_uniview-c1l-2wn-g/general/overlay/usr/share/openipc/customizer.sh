#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc335de_lite_uniview-c1l-2wn-g-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .image.mirror true
cli -s .image.flip true
cli -s .video0.codec h264
cli -s .video0.fps 25
cli -s .nightMode.irCutPin1 61
cli -s .nightMode.irCutPin2 79
cli -s .nightMode.backlightPin 4
cli -s .nightMode.colorToGray true
cli -s .audio.enabled true
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 0
cli -s .audio.srate 48000
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-ssc335de-uniview-c1l-2wn-g
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#

exit 0
