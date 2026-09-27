#!/bin/sh
# XVI ISI-2010C: T31N + GC2053

fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_lite_xvi-isi-2010c-nor.tgz'
fw_setenv sensor gc2053

# PA16 / GPIO16: daylight sensor
# PB26 / GPIO58, PB25 / GPIO57: bistable IR-cut
cli -s .nightMode.lightMonitor true
cli -s .nightMode.lightSensorPin 16
cli -s .nightMode.irCutPin1 58
cli -s .nightMode.irCutPin2 57
cli -s .video0.codec h264

exit 0
