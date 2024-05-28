#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
fw_setenv upgrade 'https://github.com/akhud78/builder/releases/download/latest/gk7205v210_lite_xm-ivg-g3s-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .system.webAdmin disabled
cli -s .system.staticDir /var/www/majestic
cli -s .nightMode.irCutPin1 9
cli -s .nightMode.irCutPin2 8
cli -s .nightMode.monitorDelay 20
cli -s .nightMode.lightMonitor true
cli -s .nightMode.minThreshold 2000
cli -s .nightMode.maxThreshold 20000
#cli -s .audio.speakerPin 55
cli -s .video0.codec h264
cli -s .video0.size 1024x576
cli -s .mjpeg.size 640x360
cli -s .jpeg.qfactor 80
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm603x-generic-usb
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

fw_setenv netaddr_fallback 192.168.1.10
fw_setenv gpio_reset 52

adduser viewer -s /bin/false -D -H
echo viewer:123456 | chpasswd

exit 0
