#!/bin/sh

# Set custom upgrade url
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc337de_ultimate_foscam-x5-nor.tgz'

# Set custom majestic settings
cli -s .video0.codec h265
cli -s .video0.fps 30
cli -s .nightMode.lightSensorPin 80
cli -s .nightMode.irCutPin1 3
cli -s .nightMode.irCutSingleInvert true
cli -s .nightMode.backlightPin 0
cli -s .audio.speakerPin 14
cli -s .audio.speakerPinInvert true

# Set wlan settings
fw_setenv wlandev rtl8188fu-ssc337de-foscam

exit 0
