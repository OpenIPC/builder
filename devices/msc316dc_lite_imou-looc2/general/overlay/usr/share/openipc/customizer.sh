#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/msc316dc_lite_imou-looc2-nor.tgz'
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8192eu-msc316dc-imou-looc2
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
