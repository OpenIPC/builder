#!/bin/sh

# Set custom upgrade url
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t21_lite_smartwares-cip-37210at-nor.tgz'

# Set custom majestic settings
cli -s .image.mirror true
cli -s .image.flip true
cli -s .video0.fps 30
cli -s .nightMode.irCutPin1 50
cli -s .nightMode.backlightPin 69

# Set wlan settings
fw_setenv wlandev rtl8188fu-t21-smartwares

exit 0
