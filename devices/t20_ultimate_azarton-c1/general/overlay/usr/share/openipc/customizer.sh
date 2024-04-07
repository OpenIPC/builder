#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t20_ultimate_azarton-c1-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 25
cli -s .nightMode.irCutPin2 26
cli -s .nightMode.backlightPin 49
cli -s .video0.codec h264
cli -s .audio.speakerPin 63
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
fw_setenv osmem 64M
fw_setenv rmem 64M@0x4000000
#
exit 0
