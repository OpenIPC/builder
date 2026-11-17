#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ak3918ev300_lite_heimvision-pe3020w-nor.tgz'
#
#
# Set wlan device: RTL8188FU on USB
#
fw_setenv wlandev rtl8188fu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# IR-cut: GPIO 41 pulses the filter to day and GPIO 42 to night, each driven
# back low (measured on the board, OpenIPC/builder#234). Which of Majestic's
# two pins drives which way is not confirmed on this board yet; swap them if
# the filter moves the wrong way.
cli -s .nightMode.irCutPin1 41
cli -s .nightMode.irCutPin2 42
cli -s .video0.codec h264

exit 0
