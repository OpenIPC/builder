#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# Zenointel SD-2N-4G: GK7205V510, MIS2009, 128 MB SPI-NAND, pan/tilt head,
# Quectel EC200A-EU 4G modem (see /etc/init.d/S45modem)
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7205v510_ultimate_zenointel-sd-2n-4g-nand.tgz'
#
#
# Set custom majestic settings
#
# MIS2009, which ipctool reports as mis2008 (same address and ID): name the
# driver and the stock firmware's tuning for it, since neither can be found
# by the sensor's name.
cli -s .isp.sensorConfig /etc/sensors/mis2009_i2c_1080p.ini
cli -s .isp.iqProfile /etc/sensors/iq/mis2009.ini
cli -s .nightMode.irCutPin1 11
cli -s .nightMode.irCutPin2 10
# Lamps: the stock firmware calls them its near and far smartIR lamps, but
# measured with a chart PWM8 (pad GPIO56) is the IR lamp and PWM9 (pad GPIO55)
# a cool white LED -- its own config says IrLedCh 0, WhiteLedCh 1. Night lights
# the IR lamp; nightMode.colorNight lights the white one instead and keeps the
# picture in colour. The IR pad is the one a majestic that cannot drive PWM
# falls back to switching.
cli -s .nightMode.backlightPin 56
cli -s .nightMode.irLightPwmChannel pwm8
cli -s .nightMode.whiteLightPwmChannel pwm9
cli -s .audio.speakerPin 28
# Pan/tilt through majestic-af's gpiostep actuator (/ptz, ONVIF, WebUI). The
# WebUI draws its pad from these two: the method, and the axes the head has.
cli -s .isp.autofocus.enabled true
cli -s .isp.autofocus.actuator gpiostep
fw_setenv ptz_control gpiostep
fw_setenv ptz_caps 'pan tilt'

exit 0
