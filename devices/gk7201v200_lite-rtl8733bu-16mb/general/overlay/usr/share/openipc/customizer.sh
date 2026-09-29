#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7201v200_lite-rtl8733bu-16mb-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCut off
cli -s .audio.enabled true
cli -s .audio.volume 50
cli -s .audio.srate 32000
cli -s .audio.codec aac
#cli -s .nightMode.colorToGray true
#cli -s .motionDetect.enabled true
#cli -s .motionDetect.visualize false
#cli -s .motionDetect.debug true
cli -s .onvif.enabled true
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev rtl8733bu-gk7205v200-camhi
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
fw_setenv totalmem 64M
fw_setenv osmem 32M
#
(sleep 3 ; reboot -f) &
#

exit 0
