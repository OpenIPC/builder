#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# XM board IPC-RM1-BLK7202V3-M43A-WIFI (GK7202V300 + SC223A, Wi-Fi SV6115C or RTL8188EUS on USB),
# pan/tilt dome. GPIOs taken from the stock firmware (loadpublic gpio_pin=, LIBXMVIDEO.json).
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7202v300_lite_xm-rm1-nor.tgz'
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev gk7202v300-xm-rm1
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# Pan/tilt: two unipolar steppers driven straight from GPIO (gpio-motors).
# Pan coils first, then tilt; phase order checked on hardware for direction.
#
fw_setenv ptz_control gpio
fw_setenv ptz_gpio '52 53 54 55 12 14 15 13'
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
