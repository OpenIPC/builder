#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# XM board IPC-RM1-BLK7202V3-M43A-WIFI (GK7202V300 + SC223A, Wi-Fi SV6115C on USB),
# pan/tilt dome. GPIOs taken from the stock firmware (loadpublic gpio_pin=, LIBXMVIDEO.json).
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7202v300_lite_xm-rm1-nor.tgz'
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev ssv6x5x-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# Pan/tilt: two unipolar steppers driven straight from GPIO (gpio-motors)
#
fw_setenv ptz_control gpio
fw_setenv ptz_gpio '13 15 14 12 55 54 53 52'
fw_setenv ptz_caps 'pan tilt'
#
# Set majestic settings
#
cli -s .nightMode.irCutPin1 56
cli -s .nightMode.irCutPin2 58
cli -s .nightMode.backlightPin 16
cli -s .nightMode.lightMonitor true
cli -s .nightMode.lightSensorPin 57
cli -s .audio.enabled true
cli -s .audio.outputEnabled true
cli -s .audio.speakerPin 51

exit 0
