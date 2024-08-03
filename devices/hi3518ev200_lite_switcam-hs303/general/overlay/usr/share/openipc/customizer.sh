#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_lite_switcam-hs303-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 64
cli -s .nightMode.backlightPin 65
cli -s .nightMode.lightMonitor true
cli -s .nightmode.lightSensorPin 62
cli -s .nightmode.lightSensorInvert false
cli -s .video0.codec h264
cli -s .audio.enabled true
cli -s .audio.volume 40
cli -s .audio.srate 8000
cli -s .audio.codec alaw
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 32
cli -s .audio.speakerPinInvert true
#
#
# Set wlan device and credentials if need
#
#  fw_setenv wlandev rtl8188eu-hi3518ev200-qvc-ipc-136w
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Other custom settings
#
fw_setenv extras initcall_blacklist=hisi_femac_driver_init
fw_setenv board hs303-v1
#fw_setenv osmem 45M
#
exit 0
