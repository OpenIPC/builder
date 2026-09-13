#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev300_lite_generic-rtl8188eu-nor.tgz'
#
# rtl8188eu-generic is the /etc/wireless/usb profile that runs `modprobe 8188eu`,
# which is the module rtl8188eus-openipc builds. The in-tree staging driver this
# SoC used to carry was called r8188eu and nothing ever modprobed it.
#
fw_setenv wlandev rtl8188eu-generic
#
#
# Set wlan device and credentials if need
#
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#

exit 0
