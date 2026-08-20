#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# GK-W7 (product string ipc533331a-W7-gc2053dvp-f8): GK7202V300, 8MB NOR,
# GC2053 wired in DVP/parallel mode with the SID strap HIGH, and an
# iComm/SSV SSV6006C USB Wi-Fi part (USB ID 8065:6000).
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7202v300_lite_w7_8m-nor.tgz'
#
# Set wlan device and credentials if need
#
fw_setenv wlandev ssv6x5x-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# DVP SENSOR BRING-UP.
#
# This board routes the GC2053's parallel data, sync, PCLK and i2c to the
# SoC's DVP pads, not its MIPI lanes. open_sys_config picks the pad routing
# from its insmod arguments, and the generic gk7202v300 arguments select the
# MIPI path — which muxes the i2c controller to pads that are not connected
# to anything here, so every address NACKs and no sensor is ever found.
#
# sensor_dvp tells load_goke to take the DVP branch. It is read as an
# opt-in env var rather than keyed off the SoC name, because MIPI-wired
# gk7202v300 boards exist and must keep the current behaviour.
#
fw_setenv sensor_dvp 1
fw_setenv sensor gc2053
#
# The shipped gc2053_i2c_1080p.ini declares MIPI input. Pin the DVP variant
# explicitly rather than relying on ini-glob ordering.
#
cli -s .isp.sensorConfig /etc/sensors/gc2053_i2c_dc_1080p.ini
#
# Set majestic settings
#
cli -s .audio.enabled true
cli -s .audio.outputEnabled true

exit 0
