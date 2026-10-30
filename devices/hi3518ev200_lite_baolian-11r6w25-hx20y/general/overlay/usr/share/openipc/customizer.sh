#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_lite_baolian-11r6w25-hx20y-nor.tgz'
#
#
# Sensor: a parallel JX-H65 wired to the low VI pins. The shared
# jxh65_i2c_960p.ini does not fit it (pink picture), so the camera is pointed
# at the profile measured on it (OpenIPC/firmware#2675).
#
fw_setenv sensor jxh65
cli -s .isp.sensorConfig /etc/sensors/dvp_jxh65_960p.ini
#
# Lens: zoom and focus steppers, coils in order, active-low, decoded from the
# factory motor.ko. muxes.sh homes and parks it on every boot.
#
fw_setenv ptz_gpio '31 33 3 32 49 7 34 6'
fw_setenv ptz_coil_active 0
#
# Set wlan device and credentials if need
#
fw_setenv wlandev mt7601u-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
