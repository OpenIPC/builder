#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t23_lite_jooan-a6m-u-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .nightMode.irCutPin1 49
cli -s .nightMode.irCutPin2 50
cli -s .nightMode.backlightPin 59
cli -s .nightMode.monitorDelay 5
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
cli -s .audio.speakerPinInvert true
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm601x-t23-jooan-a6m-u
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
# Set motor and mmc
#
fw_setenv gpio_mmc 61
#fw_setenv gpio_motors 53 52 54 14 17
#
#
#adduser viewer -s /bin/false -D -H ; echo viewer:123456 | chpasswd
#
(sleep 3 ; reboot -f) &
#

exit 0
