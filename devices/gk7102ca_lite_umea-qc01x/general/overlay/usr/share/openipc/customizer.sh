#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7102ca_lite_umea-qc01x-nor.tgz'
#
#
# Set custom majestic settings
#
#cli -s .nightMode.lightMonitor true
#cli -s .nightMode.lightSensorPin 23
#cli -s .nightMode.irCutPin1 17
#cli -s .nightMode.irCutPin2 14
#cli -s .nightMode.backlightPin 24
#cli -s .audio.speakerPin 12
#cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev rda-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# reset gpio - 16
# wifi gpio - 4
#
exit 0
