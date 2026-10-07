#!/bin/sh
#
# Zenointel SD-2N-4G board setup. S30customizer runs this on every boot, before
# the network, the vendor modules and majestic. Pins are from the stock firmware's
# board config (cfgshow) and its init.sh.
#
# Image sensor (MIS2008) power-down: the stock firmware drives it low at boot. Left
# floating high, the sensor still answers I2C but never starts its MIPI output, and
# majestic sees only "Timeout from venc".
gpio clear 50
#
# microSD slot power. The stock init.sh also re-muxes pad 0x100c005c (0x0, then
# 0x1) to get a card noticed, but the built-in SD host has already detected the card
# by the time this runs: the toggle cuts it off, its first read times out, and the
# write clobbers the pad's drive/pull bits (the driver leaves 0x531).
gpio clear 38
#
# The two pads the stock firmware takes from JTAG to GPIO when the board has an
# audio output.
devmem 0x120c0010 32 0x2
devmem 0x120c0014 32 0x2
#
# Lamps: both are majestic's (nightMode.irLightPwmChannel / whiteLightPwmChannel).
# Hold them dark until it muxes their pads to PWM.
gpio clear 56
gpio clear 55
#
# Pan/tilt: two 4-wire steppers on GPIO. majestic drives them through majestic-af's
# gpiostep actuator; the head's travel is in /etc/gpiostep.conf.
insmod /lib/modules/$(uname -r)/extra/gpiostep.ko pan_gpios=3,4,72,73 tilt_gpios=69,59,58,57
