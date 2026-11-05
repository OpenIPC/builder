#!/bin/sh

### focus coil on GPIO0_6, a pad that boots as FLASH_TRIG ###
devmem 0x200f0008 32 0

### night lamps: IR, not white ###
# GPIO7_7 boots as SAR_ADC_CH1. It only picks which lamps may light, high for
# IR and low for white; the camera's own light sensor switches them on and off
# (#2675). White lights that sensor up and flashes every few seconds, so IR is
# the default. `gpio clear 63` selects white until the next boot.
devmem 0x200f00fc 32 1
gpio set 63 >/dev/null

### home the lens, then park it at wide, focused at a few metres ###
# A stepper has no idea where it is after a power cut, so this runs on every
# boot: zoom to its tele stop, focus to its near stop, then out by the counts
# measured on this camera (zoom 0..370, focus peak 168..171 at wide, #2675).
# In the background, so the boot does not wait for it, with what gpio-motors
# says and the outcome in syslog under "lens": a lens left out of position
# should say why. Only with a gpio-motors that knows active-low coils: an
# older one drives these inverted and leaves both motors energised.
lens_home() {
	if gpio-motors -400 -530 3 && gpio-motors 370 170 3; then
		echo "homed, parked at zoom 370 focus 170"
	else
		echo "homing failed: lens position unknown"
	fi
}
if grep -q ptz_coil_active /usr/bin/gpio-motors 2>/dev/null; then
	lens_home 2>&1 | logger -t lens &
else
	logger -t lens "gpio-motors does not know ptz_coil_active; lens left alone"
fi
