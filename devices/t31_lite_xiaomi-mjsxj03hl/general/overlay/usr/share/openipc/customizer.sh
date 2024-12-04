#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_lite_xiaomi-mjsxj03hl-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .system.plugins true
cli -s .isp.blkCnt 1
cli -s .nightMode.irCutPin1 49
cli -s .nightMode.irCutPin2 50
cli -s .nightMode.backlightPin 60
cli -s .nightMode.lightMonitor true
cli -s .nightMode.minThreshold 10
cli -s .nightMode.maxThreshold 100
cli -s .video0.codec h264
cli -s .onvif.enabled false
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8189fs-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set osmem and rmem
#
fw_setenv osmem 32M
fw_setenv rmem 32M@0x2000000
#
exit 0
