#!/bin/sh

### set leds to off ###
gpio clear 35

### home the pan/tilt stage the first time it has no position ###
# The stage position is what /etc/ptz_state records, and homing drives the pan
# axis into its end stop to find it. A firmware upgrade leaves /etc alone, so
# this only runs after a wipe or on a board that has never been homed -- which
# is the one case where the stored position is genuinely unknown.
if [ ! -f /etc/ptz_state ]; then
	(gpio-motors home >/dev/null 2>&1) &
fi