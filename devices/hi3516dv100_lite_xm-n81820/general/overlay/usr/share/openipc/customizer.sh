#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# XiongMai HI3516D_N81820: hi3516dv100 (HiSilicon Hi3516A/D V100) + Sony IMX291
# on the DC/parallel interface, with a Panasonic MS41908M motorized zoom/focus
# lens (LENS_LH13_FHD_X16). Unlike the XM near-Pelco lenses, this motor is NOT on
# a UART: it is an SPI stepper on /dev/spidev1.0, driven by majestic-af's
# `ms41908` actuator. So there is no console-UART sharing to work around here.
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
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516dv100_lite_xm-n81820-nor.tgz'
#
#
# Autofocus / zoom / focus: majestic's contrast AF over the ISP focus statistic,
# driving the MS41908M over SPI through the majestic-af `ms41908` backend. The
# SPI actuator is not reachable via the ptz_control env (that path only knows the
# pelco protocols), so it is selected directly in majestic's config. The backend
# sets up the SPI1 pinmux itself; /dev/spidev1.0 is present out of the box.
#
cli -s .isp.autofocus.enabled true
cli -s .isp.autofocus.actuator ms41908
#
#
# Reboot so the environment takes effect.
#
(sleep 3 ; reboot -f) &
#

exit 0
