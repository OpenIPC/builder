#!/bin/sh
#
# Perform basic settings on a known IP camera
#

#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_ultimate_tplink-kasa-kc110-nor.tgz'
fw_setenv wlandev 'rtl8188fu-generic'

#
# Set custom majestic settings
#
cli -s .isp.sensorConfig /etc/sensors/ov2735_i2c_1080p.ini
cli -s .nightMode.irCutPin1 64
cli -s .nightMode.irCutSingleInvert false
cli -s .nightMode.backlightPin 63
cli -s .nightMode.lightMonitor true

exit 0
