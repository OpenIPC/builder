#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set osmem & sensor
#
fw_setenv osmem 64M
fw_setenv sensor sc2330
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516ev300_ultimate_rvi-1ncmw2028-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .nightMode.irCutPin1 67
cli -s .nightMode.irCutPin2 66
cli -s .nightMode.backlightPin 73
cli -s .nightMode.colorToGray true
cli -s .nightMode.lightMonitor false
cli -s .nightMode.monitorDelay 5
cli -s .nightMode.minThreshold 5000
cli -s .nightMode.maxThreshold 20000
cli -s .audio.enabled true
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.srate 48000
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
