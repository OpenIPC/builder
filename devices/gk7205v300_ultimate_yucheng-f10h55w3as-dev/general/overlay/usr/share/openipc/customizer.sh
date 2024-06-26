#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
fw_setenv upgrade 'https://github.com/akhud78/builder/releases/download/latest/gk7205v300_ultimate_yucheng-f10h55w3as-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .system.webAdmin disabled
cli -s .system.staticDir /var/www/majestic
cli -s .nightMode.irCutPin1 11
cli -s .nightMode.irCutPin2 10
cli -s .nightMode.monitorDelay 20
cli -s .nightMode.lightMonitor true
cli -s .nightMode.minThreshold 2000
cli -s .nightMode.maxThreshold 20000
#
cli -s .video0.codec h264
# cli -s .mjpeg.size 640x360
cli -s .jpeg.qfactor 80
cli -s .jpeg.size 1024x576
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev mt7601u-gk7205v300-camhi
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

fw_setenv netaddr_fallback 192.168.1.10
fw_setenv gpio_reset 42

adduser viewer -s /bin/false -D -H
echo viewer:123456 | chpasswd
#
# fix sd card format
sed -i 's/exfat/vfat/g' /var/www/cgi-bin/fw-sdcard.cgi

exit 0
