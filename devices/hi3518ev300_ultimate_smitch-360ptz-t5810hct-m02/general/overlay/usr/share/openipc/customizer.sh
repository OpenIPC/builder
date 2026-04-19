#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set sensor
#
fw_setenv sensor jxf23
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev300_ultimate_smitch-360ptz-t5810hct-m02-nor.tgz'
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .audio.enabled true
cli -s .audio.codec opus
cli -s .audio.volume 30
cli -s .audio.srate 48000
#
# Set wlan device
#
fw_setenv wlandev rtl8188fu-hi3518ev300-t5810hct-m02
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
exit 0