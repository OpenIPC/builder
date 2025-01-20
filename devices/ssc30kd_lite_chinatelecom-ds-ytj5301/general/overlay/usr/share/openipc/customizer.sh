#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc30kd_lite_chinatelecom-ds-ytj5301-nor.tgz'
#
#
# Set custom majestic settings
#
#cli -s .image.mirror true
#cli -s .image.flip true
#cli -s .nightMode.irCutPin1 61
#cli -s .nightMode.irCutPin2 79
#cli -s .nightMode.backlightPin 4
cli -s .nightMode.colorToGray true
#cli -s .audio.speakerPin 0
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-ssc30kq-chinatelecom-ds-ytj5301
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
