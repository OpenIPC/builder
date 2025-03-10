#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gm8136_lite_faleemi-fcs880-nor.tgz'
fw_setenv soc gm8136
fw_setenv sensor ps5230
fw_setenv resolution 1080p
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 61           
cli -s .nightMode.irCutPin2 60
cli -s .nightMode.backlightPin 31
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

