#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t23_lite_lsc-3215672-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .nightMode.irCutPin1 58
cli -s .nightMode.irCutPin2 57
cli -s .nightMode.backlightPin 61
cli -s .nightMode.monitorDelay 5
cli -s .nightMode.lightMonitor true
cli -s .nightMode.minThreshold 10
cli -s .nightMode.maxThreshold 100
cli -s .osd.enabled true
cli -s .osd.template "OpenIPC | %F %T %Z"
cli -s .audio.enabled true
cli -s .audio.codec aac
cli -s .audio.srate 48000
cli -s .audio.volume 95
cli -s .audio.gain 25
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 63
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm601x-t23-lsc-3215672
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set osmem and rmem
#
fw_setenv osmem 45M@0x0
fw_setenv rmem 19M@0x2D00000
#
#
#adduser viewer -s /bin/false -D -H ; echo viewer:123456 | chpasswd
#
(sleep 3 ; reboot -f) &
#

exit 0
