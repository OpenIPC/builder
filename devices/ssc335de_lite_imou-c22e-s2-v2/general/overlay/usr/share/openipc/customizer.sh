#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc335de_lite_imou-c22e-s2-v2-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .system.staticDir /var/www/majestic
#cli -s .image.mirror true
#cli -s .image.flip true
#cli -s .nightMode.irCutPin1 61
#cli -s .nightMode.irCutPin2 79
#cli -s .nightMode.backlightPin 4
#cli -s .nightMode.colorToGray true
#cli -s .audio.speakerPin 0
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev rtl8188fu-imou-c22e-s2-v2
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
