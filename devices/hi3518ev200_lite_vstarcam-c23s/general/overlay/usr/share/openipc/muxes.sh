#!/bin/sh
#
# VStarcam C23S board pinmux preset.
# S30customizer runs this script on every boot.
#
# The Darlington array feeding the pan stepper (CHMC 1J2003EF on the foot
# board) takes its inputs from GPIO3_7 and GPIO4_0..GPIO4_2 - pads 31 to 34.
# The BSP leaves them as inputs with the internal pull-up, so they read 1 from
# the first second of uptime and every coil carries current: the motor heats
# up without ever turning (OpenIPC/openhisilicon#305).
#
# On this board a coil is on when its input is high, so writing 0 switches it
# off; ptz_coil_active is 1, the default. Pads 35 and 36 sit in the same block
# and are left alone: what they drive is not identified.
#
for p in 31 32 33 34; do
	echo "$p" > /sys/class/gpio/export 2>/dev/null
	echo out > "/sys/class/gpio/gpio$p/direction" 2>/dev/null
	echo 0   > "/sys/class/gpio/gpio$p/value" 2>/dev/null
done
