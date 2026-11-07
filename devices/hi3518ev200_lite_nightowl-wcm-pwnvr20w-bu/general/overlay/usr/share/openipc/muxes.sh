#!/bin/sh

### pads the board uses as GPIOs, not their boot functions ###
devmem 0x200f00fc 32 1   # GPIO7_7 (63, IR LEDs), boots as SAR_ADC_CH1
devmem 0x200f0068 32 0   # GPIO4_5 (37, speaker amp), boots as USB_OVRCUR
devmem 0x200f00f8 32 1   # GPIO7_6 (62, light sensor read as a logic input), boots as SAR_ADC_CH0
