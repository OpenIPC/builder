#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# ZMODO ZP-IBH15-S: hi3518cv100 (HiSilicon Hi3518C V100), 16M NOR, SOI JX-H22
# on I2C 0x60 at 24 MHz. The sensor's power pin is set in muxes.sh, so the
# sensor is left to detection rather than named here.
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518cv100_lite_zmodo-zp-ibh15-s-nor.tgz'
#
#
# IR-cut: a single pin, GPIO18 (GPIO2_2), low for day and high for night,
# as the stock ap1511.ko drives it.
#
cli -s .nightMode.irCutPin1 18
#

exit 0
