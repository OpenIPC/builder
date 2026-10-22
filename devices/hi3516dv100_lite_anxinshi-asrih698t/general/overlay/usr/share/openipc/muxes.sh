#!/bin/sh
#
# Anxinshi ASRIH698T-020-20X pinmux preset; S30customizer runs it on every
# boot, before majestic opens the port.
#
# The pan/tilt MCU sits behind an RS-485 transceiver on UART1. The stock
# firmware muxes UART1 RXD/TXD and keeps the UART1_RTSN ball as GPIO9_2,
# driven as the transceiver's direction pin (Hi3516A/D datasheet table 2-48;
# OpenIPC/firmware#2385). GPIO9_2 resets low, which is receive, so nothing
# majestic sends would reach the bus. Pan/tilt frames need no reply, so the
# pin is held high.
#

devmem 0x200f0078 32 0
devmem 0x200f007c 32 1
devmem 0x200f0084 32 1

dir=$(devmem 0x201d0400)
devmem 0x201d0400 32 $((dir | 0x4))
devmem 0x201d0010 32 0x4
