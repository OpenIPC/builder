#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_lite_switcam-hs303-v2-nor.tgz'
#
#
# Set majestic settings
#
cli -s .isp.blkCnt 5
cli -s .nightMode.irCutPin1 2
#cli -s .nightMode.lightMonitor true
cli -s .nightMode.lightSensorPin 62
cli -s .nightMode.lightSensorInvert true
cli -s .video0.codec h264
cli -s .video0.fps 20
cli -s .audio.enabled true
cli -s .audio.volume 40
cli -s .audio.srate 48000
cli -s .audio.codec opus
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 53
cli -s .audio.speakerPinInvert true
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188eus-switcam-hs303v2
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Other custom settings
#
fw_setenv extras initcall_blacklist=hisi_femac_driver_init
fw_setenv board hs303-v2
#fw_setenv osmem 45M
#
exit 0
