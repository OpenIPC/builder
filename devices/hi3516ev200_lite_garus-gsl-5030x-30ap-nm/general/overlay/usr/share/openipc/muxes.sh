#!/bin/sh
#
# GARUS GSL-5030X-30AP-NM: GPIO15 is GPIO1_7.
# Make it an input before switching the pad to GPIO mode. Preserve all
# unrelated direction and pad-control bits.
#

set -e

direction=$(devmem 0x120B1400 32)
devmem 0x120B1400 32 $((direction & 0xffffff7f))

pinmux=$(devmem 0x120C001C 32)
devmem 0x120C001C 32 $(((pinmux & 0xfffffff0) | 0x2))
