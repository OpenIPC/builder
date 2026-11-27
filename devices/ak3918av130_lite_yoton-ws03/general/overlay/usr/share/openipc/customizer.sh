#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# Yoton WS03: AK3918AV130, SmartSens SC3B2AQ/SC4336 (no OpenIPC driver yet),
# 8 MB NOR, AltoBeam ATBM6132-C USB Wi-Fi, pan/tilt. Board
# GV-AK130-PTZ-MAIN-V2.5 (OpenIPC/firmware#2962).
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ak3918av130_lite_yoton-ws03-nor.tgz'
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm606x-generic-usb
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
