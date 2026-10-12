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
