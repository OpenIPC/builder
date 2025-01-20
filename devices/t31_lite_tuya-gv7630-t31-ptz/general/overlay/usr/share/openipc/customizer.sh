#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_lite_tuya-gv7630-t31-ptz-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .isp.blkCnt 1
#cli -s .audio.speakerPin ??
#cli -s .nightMode.lightMonitor true
#cli -s .nightMode.irCutPin1 ??
#cli -s .nightMode.irCutPin2 ??
#cli -s .nightMode.backlightPin ??
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm603x-usb-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set osmem and rmem
#
#fw_setenv osmem 39M
#fw_setenv rmem 25M@0x2700000
#
exit 0
