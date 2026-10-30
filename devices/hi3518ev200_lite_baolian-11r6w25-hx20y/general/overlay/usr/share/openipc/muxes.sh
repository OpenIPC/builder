#!/bin/sh

### focus coil on GPIO0_6, a pad that boots as FLASH_TRIG ###
devmem 0x200f0008 32 0

### home the lens, then park it at wide, focused at a few metres ###
# A stepper has no idea where it is after a power cut, so this runs on every
# boot: zoom to its tele stop, focus to its near stop, then out by the counts
# measured on this camera (zoom 0..370, focus peak 168..171 at wide, #2675).
# In the background, so the boot does not wait for it. Only with a gpio-motors
# that knows active-low coils: an older one drives these inverted and leaves
# both motors energised.
if grep -q ptz_coil_active /usr/bin/gpio-motors 2>/dev/null; then
	(gpio-motors -400 -530 3 && gpio-motors 370 170 3) >/dev/null 2>&1 &
fi
