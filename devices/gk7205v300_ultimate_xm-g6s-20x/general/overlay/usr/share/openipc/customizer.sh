#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# XiongMai IPC_GK7205V300_G6S with the 20x zoom block (sold as IVG-G5S-20X,
# stock DEVID K40699Q3): gk7205v300 + imx335 behind a 4.7-94 mm motorized
# zoom/focus lens. The same board with a plain lens is
# gk7205v300_lite_vixand-ivg-g6s. The lens MCU shares /dev/ttyAMA0 with the
# serial console at 115200 and takes the same C5 ... 5C near-Pelco frames as
# the 85H50AI's (motors xm-uart/PROTOCOL.md, "Newer revision").
#
#
# Set sensor
#
fw_setenv sensor imx335
#
# Set custom upgrade url
#
# The coupler's generic lite image (DEVID K40699Q3) runs the same split NOR
# layout and has no customizer, so `sysupgrade --archive=<device>-nor-split.tgz`
# from it lands here with no /etc/custom.ok and this runs on the first boot.
# sysupgrade finds the -split package beside the plain one at this URL.
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7205v300_ultimate_xm-g6s-20x-nor.tgz'
#
#
# PTZ: the XM zoom block on the console UART. ptz_caps narrows the WebUI
# pad to what the hardware has: a zoom block with no pan/tilt head.
#
fw_setenv ptz_control pelco-xm
fw_setenv ptz_port /dev/ttyAMA0
fw_setenv ptz_caps 'zoom focus'
#
#
# Autofocus: majestic's contrast AF engine over the ISP focus statistic,
# driving the same zoom block. Default port/speed already match this board.
#
cli -s .ptz.enabled true
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
