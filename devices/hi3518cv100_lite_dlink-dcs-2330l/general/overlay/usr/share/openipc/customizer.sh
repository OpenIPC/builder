#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518cv100_lite_dlink-dcs-2330l-nor.tgz'
#
#
# Set custom majestic settings
#
# This board wires the OV9712 to VI bits 22-31, not the 20-29 of the stock ini
cli -s .isp.sensorConfig /etc/sensors/ov9712_i2c_dc_720p_dcs2330l.ini
cli -s .nightMode.irCutPin1 0
cli -s .nightMode.lightMonitor true
cli -s .video0.codec h264
cli -s .video0.fps 20
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188eu-dlink-dcs-2330l
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#

exit 0
