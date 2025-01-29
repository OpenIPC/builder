#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516cv200_lite_trassir-tr-d4121ir1-v2-nor.tgz'
#
#
# Set custom majestic settings
#
#cli -s .nightMode.lightMonitor true
cli -s .nightMode.lightSensorPin 62
cli -s .nightMode.irCutPin1 64
cli -s .nightMode.irCutSingleInvert true
cli -s .nightMode.backlightPin 63
cli -s .video0.codec h264
cli -s .video0.fps 30
cli -s .isp.slowShutter disabled
#

exit 0
