#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7205v300_lite_vixand-ivg-g6s-w-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .isp.blkCnt 5
cli -s .isp.drc 200
cli -s .video0.codec h264
cli -s .video0.bitrate 7168
cli -s .video0.rcMode vbr
cli -s .video0.fps 25
cli -s .video0.size 2592x1520
cli -s .video1.enabled true
cli -s .video1.fps 15
cli -s .video1.size 704x396
cli -s .jpeg.size 1920x1080
cli -s .jpeg.qfactor 80
cli -s .osd.enabled true
#cli -s .osd.posX 10
#cli -s .osd.posY 10
cli -s .osd.template "VIXAND | %F %T %Z"
cli -s .audio.enabled true
cli -s .audio.volume 50
cli -s .audio.srate 32000
cli -s .audio.codec aac
#cli -s .audio.speakerPin 55
cli -s .nightMode.colorToGray false
#cli -s .nightMode.irCutPin1 11
#cli -s .nightMode.irCutPin2 10
cli -s .nightMode.backlightPin 4
cli -s .nightMode.lightMonitor true
cli -s .nightMode.minThreshold 1800
cli -s .nightMode.maxThreshold 32000
cli -s .motionDetect.enabled true
cli -s .motionDetect.visualize false
cli -s .motionDetect.debug true
cli -s .onvif.enabled true
cli -s .netip.enabled true
cli -s .netip.user viewer
cli -s .netip.password tlJwpbo6
cli -s .netip.ignoreSetTime true
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm603x-gk7205v300-xm-g6s
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
fw_setenv totalmem 128M
fw_setenv osmem 64M
set_allocator cma
#
(sleep 3 ; reboot -f) &
#

exit 0
