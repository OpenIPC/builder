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
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7202v300_lite_generic-w7-nor.tgz'
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
#
# ...and 24 MHz MCLK. This is NOT optional on this board, and it is not
# something the ini can supply: majestic's ini is read in userspace, while MCLK
# is an SoC clock programmed from the CRG before any of that runs.
#
# parse_sensor_clock() maps gc2053 to 0x6, and PERI_CRG60 bits [5:2] = 0x6 is
# 27 MHz. Measured on hardware: the register reads 0x00000019 at the moment
# load_goke would write it — bits [5:2] = 0x6, i.e. exactly that 27 MHz default.
# The GC2053 ForCar PLL tables this profile relies on are 24 MHz values, so
# without this the sensor is clocked 12.5% fast against its own init table.
#
fw_setenv sensor_mclk 24
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
