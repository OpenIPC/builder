#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc337de_lite_zte-k543-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .nightMode.irCutPin1 79
cli -s .nightMode.irCutPin2 78
cli -s .nightMode.backlightPin 52
cli -s .nightMode.colorToGray true
cli -s .audio.enabled true
cli -s .audio.codec pcm
cli -s .audio.srate 8000
cli -s .audio.inputChannel 1
cli -s .audio.volume 70
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 60
cli -s .audio.speakerPin 15
cli -s .audio.speakerPinInvert true
#
#
# Set wlan device and credentials if needed
#
fw_setenv wlandev "mt7601sta-ssc337de-zte-k543"
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set ptz motor pins
#
fw_setenv ptz_control gpio
fw_setenv ptz_gpio '0 1 2 3 4 5 6 7'
#
#
# Status LEDs:
#   GPIO 76
#   GPIO 77
#
exit 0
