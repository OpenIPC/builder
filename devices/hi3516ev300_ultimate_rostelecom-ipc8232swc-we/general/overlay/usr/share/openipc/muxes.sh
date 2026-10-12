#!/bin/sh

### set leds power off ###
gpio set 10
gpio set 25

### sd card power en ###
devmem 0x100c0058 32 0
gpio set 38
# The kernel scanned mmc0 at boot, while the slot was still unpowered, and
# this board's card detect never changes, so nothing scans it again: rebind
# the host so it finds the card now that it has power.
sd=/sys/bus/platform/drivers/sdhci-hisi
if [ -e $sd/10010000.sdhci ] && [ -z "$(ls /sys/class/mmc_host/mmc0 | grep mmc0:)" ]; then
	echo 10010000.sdhci > $sd/unbind
	echo 10010000.sdhci > $sd/bind
fi

### settings an earlier version of this profile wrote ###
# customizer.sh runs once, so a camera set up by an earlier version of this
# profile keeps the upgrade URL it pinned: the -nor.tgz package, which a NAND
# camera cannot install. Cleared only while it is exactly that URL, so one the
# owner chose stays; sysupgrade then picks <platform>-<nor|nand>.tgz itself.
old=https://github.com/OpenIPC/builder/releases/download/latest/hi3516ev300_ultimate_rostelecom-ipc8232swc-we-nor.tgz
[ "$(fw_printenv -n upgrade 2>/dev/null)" = "$old" ] && fw_setenv upgrade
