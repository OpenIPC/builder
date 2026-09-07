#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/xm530_lite_anbiux-a8b-3mp-nor.tgz'
#
# Set wlan device, its PDN gpio and credentials if need
#
fw_setenv wlandev atbm603x-xm530-usb
fw_setenv wifipdn 96
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
(sleep 3 ; reboot -f) &

exit 0
