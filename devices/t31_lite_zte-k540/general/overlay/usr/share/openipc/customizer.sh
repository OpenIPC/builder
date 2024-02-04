#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_lite_zte-k540-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.enabled true
cli -s .nightMode.irCutPin1 57
cli -s .nightMode.irCutPin2 58
cli -s .nightMode.backlightPin 11
cli -s .video0.codec h264
cli -s .audio.speakerPin 64
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm603x_wifi_usb
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set osmem and rmem
#
fw_setenv osmem 64M
fw_setenv rmem 64M@0x4000000
#
exit 0
