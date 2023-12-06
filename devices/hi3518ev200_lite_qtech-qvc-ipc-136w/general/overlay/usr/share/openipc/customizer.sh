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
cli -s .system.staticDir /var/www/majestic
cli -s .nightMode.enabled true
cli -s .nightMode.irCutPin1 48
cli -s .nightMode.irCutPin2 47
cli -s .nightMode.backlightPin 59
cli -s .audio.speakerPin 53
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188eu-hi3518ev200-qvc-ipc-136w
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0