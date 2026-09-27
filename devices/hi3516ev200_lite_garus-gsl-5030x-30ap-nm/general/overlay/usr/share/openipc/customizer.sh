#!/bin/sh
#
# OpenIPC profile for GARUS GSL-5030X-30AP-NM
# Board: BLK16EV2-4339P-38X38
# SoC: HiSilicon Hi3516EV200
# Sensor path: SC2315E, MIPI 1080p
#
# GPIO15 is the external day/night status input. GPIO8/9 drive the bistable
# IR-cut filter. The IR illuminator board is autonomous, so no backlight GPIO
# is configured here.
#

fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516ev200_lite_garus-gsl-5030x-30ap-nm-nor.tgz'
fw_setenv sensor sc2315e

cli -s .isp.sensorConfig /etc/sensors/sc2315e_i2c_1080p.ini
cli -s .nightMode.lightMonitor true
cli -s .nightMode.lightSensorPin 15
cli -s .nightMode.irCutPin1 8
cli -s .nightMode.irCutPin2 9
# The filter needs a short mechanical settle time to avoid a purple cast.
cli -s .nightMode.transitionDelayMs 150

exit 0
