#!/bin/sh
. /usr/share/openipc/gpio.conf

# sd card power enable
gpio clear $mmc_pwr
