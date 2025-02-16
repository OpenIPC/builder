#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set osmem & sensor
#
fw_setenv osmem 64M
fw_setenv sensor sc2330
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516ev300_ultimate_rvi-1ncmw2028-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .nightMode.irCutPin1 67
cli -s .nightMode.irCutPin2 66
cli -s .nightMode.backlightPin 73
cli -s .nightMode.colorToGray true
cli -s .nightMode.lightMonitor false
cli -s .nightMode.monitorDelay 5
cli -s .nightMode.minThreshold 5000
cli -s .nightMode.maxThreshold 20000
cli -s .audio.enabled true
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.srate 48000
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0

# 24 - red led
# 64 - relay
# 66 - ircut
# 67 - ircut
# 72 - white light
# 73 - ir light
# ?? - button
# ?? - light sensor
# ?? - pir sensor
# ?? - alarm in

# pwm light control
#devmem 0x100c009c 32 0x1 # pwm 2
#devmem 0x100c00a0 32 0x1 # pwm 3

# gpios
#devmem 0x100c007c 32 0x1000 # gpio 0-6 df -> vd_fz
#devmem 0x112c0074 32 0x1000 # gpio 6-4
#devmem 0x112c0090 32 0x1000 # gpio 8-2
#devmem 0x112c0094 32 0x1000 # gpio 8-3
#devmem 0x112c0040 32 0x100  # gpio 5-0 green led (flash with use wifi connection and not flash for wired)

# after sensor init
#devmem 0x120100f0 32 0x19
