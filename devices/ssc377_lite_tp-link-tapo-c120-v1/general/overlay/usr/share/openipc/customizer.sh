#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc377_lite_tp-link-tapo-c120-v1-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 81
cli -s .nightMode.irCutSingleInvert true
cli -s .nightMode.backlightPin 14
cli -s .nightMode.colorToGray true
cli -s .video0.codec h264
cli -s .video0.fps 25
cli -s .audio.speakerPin 43
cli -s .audio.srate 48000
cli -s .audio.codec pcm
cli -s .audio.enabled false
cli -s .audio.volume 0
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 60
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev  rtl8188fu-ssc377-tapo-c120
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
