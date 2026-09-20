#!/bin/sh
#
# OpenIPC profile for SpezVision SVI-252B K202
# Board: BLK16CV-0323-38X38-V1.01
# SoC: HiSilicon Hi3516CV200
# Sensor: Sony IMX323, I2C/DC
# Flash: 8 MiB SPI NOR
#
# Majestic uses legacy HiSilicon GPIO numbering: bank * 8 + bit.
#
# Stock Sofia's IMX323 day/night path for product NID 0x11 uses:
# - GPIO3_0 = 24 as the digital daylight sensor input;
# - GPIO4_2 = 34 and GPIO4_1 = 33 as the bistable IR-cut outputs.
#
# Stock code muxes GPIO3_0 with 0x200f0034 = 0 before reading it.
# The board pinmux is reapplied on every boot by /usr/share/openipc/muxes.sh,
# independently of the selected streamer.
#
# The IR illuminator control is still unresolved, so backlightPin remains
# intentionally unset.
#

fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516cv200_lite_spezvision-svi-252b-k202-nor.tgz'
fw_setenv sensor imx323

cli -s .isp.sensorConfig /etc/sensors/imx323_i2c_dc_1080p.ini
cli -s .nightMode.lightMonitor true
cli -s .nightMode.lightSensorPin 24
cli -s .nightMode.lightSensorInvert false
cli -s .nightMode.transitionDelayMs 150
cli -s .nightMode.irCutPin1 34
cli -s .nightMode.irCutPin2 33
cli -s .video0.codec h264
cli -s .video0.fps 25

exit 0
