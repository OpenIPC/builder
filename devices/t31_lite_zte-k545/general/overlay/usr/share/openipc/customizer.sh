#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_lite_zte-k545-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 57
cli -s .nightMode.irCutPin2 58
cli -s .nightMode.colorToGray true
cli -s .nightMode.backlightPin 11
cli -s .video0.codec h264
cli -s .audio.speakerPin 64
cli -s .audio.speakerPinInvert true
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm603x-t31-zte-k540
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set ptz motor pins
#
fw_setenv ptz_control gpio
fw_setenv ptz_gpio '49 63 62 61 59 52 53 54'
#
#
# Set osmem and rmem
#
fw_setenv osmem 64M
fw_setenv rmem 64M@0x4000000
#
# Status LEDs (active low: 0 = on, 1 = off):
#   Blue:  GPIO 10
#   Red:   GPIO 16
#   Green: GPIO 17
#
# Example to turn on green LED on boot:
#   echo 17 > /sys/class/gpio/export 2>/dev/null
#   echo out > /sys/class/gpio/gpio17/direction 2>/dev/null
#   echo 0 > /sys/class/gpio/gpio17/value 2>/dev/null
#
exit 0
