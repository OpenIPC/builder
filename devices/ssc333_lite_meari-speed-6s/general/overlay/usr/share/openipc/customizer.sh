#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc333_lite_meari-speed-6s-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 79
cli -s .nightMode.irCutPin2 78
cli -s .nightMode.colorToGray true
cli -s .image.mirror true
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-ssc333-meari-speed-6s
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
