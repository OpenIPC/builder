#!/bin/sh

# Set custom upgrade url
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_lite_wyze-v3b-nor.tgz'

# Set custom majestic settings
cli -s .video0.codec h265
cli -s .video0.fps 30
cli -s .nightMode.irCutPin1 53
cli -s .nightMode.irCutPin2 52
cli -s .nightMode.backlightPin 47
cli -s .audio.speakerPin 63

# Set wlan settings
fw_setenv wlandev rtl8189ftv-t31-wyze-v3

exit 0
