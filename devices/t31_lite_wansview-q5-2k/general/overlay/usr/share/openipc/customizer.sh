#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_lite_wansview-q5-2k-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .isp.blkCnt 1
cli -s .audio.speakerPin 7
cli -s .nightMode.irCutPin1 58
cli -s .nightMode.irCutPin2 57
cli -s .nightMode.backlightPin 11
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm603x-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set osmem and rmem
#
fw_setenv osmem 39M
fw_setenv rmem 25M@0x2700000
#
exit 0
