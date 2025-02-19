#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t21_lite_chinamobile-hdc-51-a5-v12-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .isp.blkCnt 1
cli -s .nightMode.lightSensorInvert true
cli -s .nightMode.irCutPin1 50
cli -s .nightMode.irCutSingleInvert true
cli -s .nightMode.adcReadout true
cli -s .nightMode.minThreshold 100
cli -s .nightMode.maxThreshold 500
cli -s .video0.codec h264
cli -s .audio.enabled true
cli -s .audio.volume 50
cli -s .audio.srate 48000
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8189fs-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
fw_setenv extras nogmac
#
#
# Set osmem and rmem
#
fw_setenv osmem 39M
fw_setenv rmem 25M@0x2700000
#

exit 0
