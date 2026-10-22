#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# Anxinshi ASRIH698T-020-20X speed dome: the XiongMai HI3516D_N81820 main
# board (hi3516dv100 + Sony IMX291 on the DC/parallel interface) in a 20x
# pan/tilt dome. Pan/tilt is an MCU in the base that speaks Pelco-D, address
# 1, 9600 8N1, over RS-485 on UART1 (OpenIPC/firmware#2385). muxes.sh puts
# UART1 on its pads and holds the transceiver in transmit on every boot.
#
# The zoom/focus lens is the board's MS41908M on SPI, as on the varifocal
# hi3516dv100_lite_xm-n81820. majestic drives one motor actuator, and here it
# is the pan/tilt head, so the lens is not driven by majestic on this image.
#
#
# Set sensor. IMX291 on this board is the DC/parallel variant, so pin its ini
# explicitly (the MIPI default would give no video).
#
fw_setenv sensor imx291
cli -s .isp.sensorConfig /etc/sensors/imx291_i2c_dc_1080p.ini
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516dv100_lite_anxinshi-asrih698t-nor.tgz'
#
#
# PTZ: Pelco-D pan/tilt on UART1. ptz_caps narrows the WebUI pad to what the
# base does; a Pelco-D zoom frame reaches it and is ignored.
#
fw_setenv ptz_control pelco-d
fw_setenv ptz_port /dev/ttyAMA1
fw_setenv ptz_speed 9600
fw_setenv ptz_caps 'pan tilt'
cli -s .ptz.enabled true
#
#
# Reboot so the environment takes effect.
#
(sleep 3 ; reboot -f) &
#

exit 0
