#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7205v200_lite_vixand-iph-5-4g-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 8
cli -s .nightMode.irCutPin2 9
cli -s .nightMode.backlightPin 14
#cli -s .audio.speakerPin 55
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev ec200n-gk7205v200-vixand
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
