#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc325_lite_imou-c22cp-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .nightMode.irCutPin1 76
cli -s .nightMode.irCutPin2 77
cli -s .nightMode.colorToGray true
#cli -s .audio.speakerPin 15
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.srate 48000
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-ssc325-imou-c22cp
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
