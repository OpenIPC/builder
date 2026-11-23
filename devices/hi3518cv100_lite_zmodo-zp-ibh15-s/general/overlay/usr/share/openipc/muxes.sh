#!/bin/sh
#
# ZMODO ZP-IBH15-S board pin preset. S30customizer runs this on every boot,
# before S70vendor loads the sensor drivers.
#
# The JXH22 is powered through GPIO5_2: until the pin is driven high, every
# I2C read at 0x60 returns 0xFF and the sensor cannot be detected or started.
# The stock firmware's vendor gpio.ko does this before hi_i2c.ko loads. U-Boot
# leaves the pad on PWM_OUT0, so mux it to GPIO5_2 first. firmware#1352.
#
devmem 0x200f00bc 32 0x0
devmem 0x20190400 32 $(( $(devmem 0x20190400) | 0x04 ))
devmem 0x20190010 32 0x04
