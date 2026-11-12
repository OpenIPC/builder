#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc377d_lite_anjoy-mc-l12d2-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .nightMode.irCutPin1 11
cli -s .nightMode.irCutPin2 80
cli -s .ptz.enabled true
#
fw_setenv ptz_control pelco-xm
fw_setenv ptz_port /dev/ttyS2
fw_setenv ptz_caps 'zoom focus'
#
fw_setenv board anjoy-mc-l12d2
#
(sleep 3 ; reboot -f) &
#

exit 0
