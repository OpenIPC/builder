#!/bin/sh

### unmute the microphone ###
# GPIO 16 mutes it while high, and nearly so when left floating as an input.
# The vendor app drives it low once the mic is on.
gpio clear 16
