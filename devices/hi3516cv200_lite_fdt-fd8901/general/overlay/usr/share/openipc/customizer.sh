#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516cv200_lite_fdt-fd8901-nor.tgz'
fw_setenv soc hi2516cv200
fw_setenv sensor sc2135
#
# Set custom majestic settings
#
cli -s .video1.enabled true
cli -s .nightMode.irCutPin1 2
cli -s .nightMode.irCutPin2 1
cli -s .nightMode.backlightPin 63
cli -s .audio.enabled true
cli -s .audio.volume 80
cli -s .audio.outputEnabled true
cli -s .audio.ouputVolume 30
cli -s .jpeg.size 1920x1080
#
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev unknown
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
adduser viewer -s /bin/false -D -H
echo viewer:123456 | chpasswd
chmod +x /etc/rc.local

exit 0

