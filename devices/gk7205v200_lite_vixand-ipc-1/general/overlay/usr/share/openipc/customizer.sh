#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7205v200_lite_vixand-ipc-1-nor.tgz'
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev ec200-gk7205v200-vixand
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
