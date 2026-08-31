#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# XiongMai 85H50AI: hi3516ev300 + imx335 with a motorized zoom/focus
# module. The motor MCU shares /dev/ttyAMA0 with the serial console at
# 115200 and speaks the XM near-Pelco protocol (btzoom-xm).
#
#
# Set sensor
#
fw_setenv sensor imx335
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516ev300_lite_xm-85h50ai-nor.tgz'
#
#
# PTZ: the XM zoom block on the console UART. ptz_caps narrows the WebUI
# pad to what the hardware has — the module accepts pan/tilt frames and
# silently ignores them (majestic-webui#227).
#
fw_setenv ptz_control pelco-xm
fw_setenv ptz_port /dev/ttyAMA0
fw_setenv ptz_caps 'zoom focus'
#
#
# Autofocus: majestic's contrast AF engine over the ISP focus statistic,
# driving the same zoom block. Default port/speed already match this board.
#
cli -s .isp.autofocus.enabled true
#
#
# The MCU owns the console UART, so getty must not sit on it reading the
# MCU's bytes. The edit lands in the overlay; an upgrade that wipes the
# overlay also wipes /etc/custom.ok, so this script runs again and the
# camera heals itself.
#
sed -i '/getty/d' /etc/inittab
#
#
# Reboot so the environment and the inittab edit take effect.
#
(sleep 3 ; reboot -f) &
#

exit 0
