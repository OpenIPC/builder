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
cli -s .video0.fps 30
#
# The [3dnr] ladder measured on this board. Without this key the streamer opens
# default.ini, which is the AR0130 one on every cv200 image.
#
cli -s .isp.iqProfile /etc/sensors/iq/c23s.ini
#
# The codec is left at the image default.
#
# Ralink MT7601U on the USB bus (148f:7601), same part as the C8892WIP
#
fw_setenv wlandev mt7601u-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# Motors: the four pan phases are GPIO 31-34, and muxes.sh holds them off at
# boot. ptz_gpio is deliberately not set here: gpio-motors wants two axes, and
# writing the pan set twice, because there is nothing else to write, would make
# a tilt request drive the pan coils. Set it once the tilt phases are known:
#   fw_setenv ptz_gpio '31 32 33 34 <tilt1> <tilt2> <tilt3> <tilt4>'
#   fw_setenv ptz_coil_active 1
#
exit 0
