#!/bin/sh

# Set custom upgrade url
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_lite_smartwares-cip-37210-nor.tgz'

# Set custom majestic settings
cli -s .video0.fps 25
cli -s .nightMode.irCutPin1 64
cli -s .nightMode.backlightPin 63
cli -s .nightMode.lightSensorPin 62
cli -s .nightMode.lightSensorInvert true
cli -s .audio.speakerPin 51
cli -s .audio.speakerPinInvert true

# Set wlan settings
fw_setenv wlandev rtl8188fu-generic

exit 0
