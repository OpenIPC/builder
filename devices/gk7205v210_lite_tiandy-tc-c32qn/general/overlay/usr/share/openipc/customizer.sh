#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# Set sensor and processor
#
fw_setenv sensor os02g10
fw_setenv soc $(ipcinfo -c)
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7205v210_lite_tiandy-tc-c32qn-nor.tgz'
#
#
# Set custom majestic settings
#

cli -s .isp.blkCnt 5
cli -s .image.mirror true
cli -s .image.flip true
cli -s .video0.codec h264
cli -s .osd.enabled true
cli -s .osd.template "OpenIPC | %F %T %Z"
cli -s .audio.enabled true
cli -s .audio.volume 50
#cli -s .nightMode.lightMonitor true
cli -s .nightMode.irCutPin1 52
cli -s .nightMode.irCutPin2 53
cli -s .nightMode.backlightPin 4
cli -s .nightMode.lightMonitor false
cli -s .nightMode.monitorDelay 5
cli -s .nightMode.minThreshold 1300
cli -s .nightMode.maxThreshold 14000
#
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev unknown
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
adduser viewer -s /bin/false -D -H
echo viewer:123456 | chpasswd
#

exit 0
