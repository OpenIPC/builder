#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_lite_vstarcam-c23s-nor.tgz'
#
#
# Sensor: OV2710 on one MIPI data lane. The default ov2710_mipi_1080p.ini
# describes the parallel interface, so the streamer moves on to
# ov2710_mipi_1lane_1080p.ini by itself; naming the sensor is enough.
#
fw_setenv sensor ov2710_mipi
#
#
# Set custom majestic settings
#
# IR-cut is on 65/64: pulsing 65 gives mean luma 154 with R/G 1.50 (filter out,
# infrared through), pulsing 64 gives 130 with R/G 0.99 (filter in).
#
cli -s .nightMode.irCutPin1 65
cli -s .nightMode.irCutPin2 64
cli -s .video0.codec h264
cli -s .video0.fps 30
#
# Ralink MT7601U on the USB bus (148f:7601), same part as the C8892WIP
#
fw_setenv wlandev mt7601u-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# Motors: four pan phases on 31-34, coils off. The head's tilt phases are not
# on these pads and its driver is not identified, so ptz_gpio gets the pan
# phases twice and tilt steps must stay 0 until that is known.
#
fw_setenv ptz_gpio '31 32 33 34 31 32 33 34'
fw_setenv ptz_coil_active 1

exit 0
