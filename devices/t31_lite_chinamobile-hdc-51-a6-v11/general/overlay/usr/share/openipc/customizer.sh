#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_lite_chinamobile-hdc-51-a6-v11-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.lightMonitor true
cli -s .nightMode.lightSensorPin 7
cli -s .nightMode.irCutPin1 58
cli -s .nightMode.irCutPin2 57
cli -s .video0.codec h264
cli -s .audio.enabled true
cli -s .audio.codec opus
cli -s .audio.srate 48000
cli -s .audio.volume 50
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 63
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set osmem and rmem
#
fw_setenv osmem 39M
fw_setenv rmem 25M@0x2700000
#
exit 0
