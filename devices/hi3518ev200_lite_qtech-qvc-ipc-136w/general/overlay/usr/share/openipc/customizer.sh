#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_lite_qtech-qvc-ipc-136w-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 48
cli -s .nightMode.irCutPin2 47
cli -s .nightMode.backlightPin 59
cli -s .nightMode.lightMonitor false    # can set true
cli -s .nightMode.minThreshold 2000
cli -s .nightMode.maxThreshold 10000
cli -s .video0.codec h264
cli -s .audio.enabled true
cli -s .audio.codec opus
cli -s .audio.srate 48000
cli -s .audio.volume 40
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 53
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188eu-hi3518ev200-qvc-ipc-136w
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
fw_setenv extras initcall_blacklist=hisi_femac_driver_init
fw_setenv board hs303-v3
#fw_setenv osmem 45M
#
exit 0
