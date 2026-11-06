#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set sensor: named here so the first boot does not have to probe for it
#
fw_setenv sensor imx662
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516cv6xx_ultimate_sip-k662c6s-nor.tgz'
#
#
# Set custom majestic settings
#
# Pins from the stock firmware. Its GPIO init drives the filter with 200 ms
# pulses, 60 for night and 61 for day, and lights the IR lamp on a low pad.
# It decides day and night from exposure, so no light sensor pin is set.
#
cli -s .nightMode.irCutPin1 60
cli -s .nightMode.irCutPin2 61
cli -s .nightMode.backlightPin 63
cli -s .nightMode.backlightInvert true
cli -s .nightMode.lightMonitor true
#
exit 0
