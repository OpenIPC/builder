#!/bin/sh
#
# Misecu XM-63-AI-50W board pinmux preset.
# S30customizer runs this script on every boot, before majestic starts.
#
# The speaker amplifier's enable (the stock Device.json's AoEn) is GPIO 73,
# but the camera's U-Boot leaves pad 73 at MUX1 (0x10020124 reads 0x2), and
# the XM530/XM550 GPIO driver refuses a muxed pad: majestic's speakerPin
# then fails with set_gpio(73, 0) error and the amplifier stays off. Clearing
# bits 1-3 (MUX1..MUX3) makes it a GPIO and keeps the pad's drive and state
# bits. Confirmed on the camera in OpenIPC/firmware#2853.
#
pad=0x10020124
devmem $pad 32 $(printf 0x%x $(( $(devmem $pad) & ~0xE )))
