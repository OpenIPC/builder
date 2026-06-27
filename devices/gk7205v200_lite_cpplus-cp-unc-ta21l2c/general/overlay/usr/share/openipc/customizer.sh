#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set sensor
#
fw_setenv sensor sc223a
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7205v200_lite_cpplus-cp-unc-ta21l2c-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .system.maxFps 30
cli -s .video0.fps 30
cli -s .video0.codec h265
cli -s .osd.enabled true
cli -s .osd.template "OpenIPC | %F %T %Z"
#
# Night mode / IR-cut and audio: the GPIO pins for the IR-cut filter and
# IR LEDs on this board are not characterised yet, so they are left at
# defaults (TODO).
#
#
# This device is wired-only (no wlan).
#
adduser viewer -s /bin/false -D -H
echo viewer:123456 | chpasswd
#
exit 0
