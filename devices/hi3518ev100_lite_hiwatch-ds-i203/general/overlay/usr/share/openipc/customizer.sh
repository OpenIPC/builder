#!/bin/sh

# Requires u-boot-hi3518ev100-ddr3-256m-universal.bin.
# The generic HI3518EV100 U-Boot does not match this board's DDR configuration.
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev100_lite_hiwatch-ds-i203-nor.tgz'

# Board-specific U-Boot environment.
fw_setenv osmem 128M
fw_setenv mtdparts 'hi_sfc:256k(boot),64k(env),3072k(kernel),10240k(rootfs),-(rootfs_data)'
fw_setenv phyaddru 3
fw_setenv extras 'hieth.phyaddru=3 hieth.mdioifu=0'
fw_setenv sensor imx122

cli -s .isp.sensorConfig /etc/sensors/imx122_spi_dc_1080p.ini

cli -s .nightMode.irCutEnabled true
cli -s .nightMode.irCutPin1 6
cli -s .nightMode.irCutPin2 5

cli -s .nightMode.backlightEnabled true
cli -s .nightMode.backlightPin 42


# Reboot once so the updated boot-time environment takes effect.
(sleep 3 ; reboot -f) &

exit 0
