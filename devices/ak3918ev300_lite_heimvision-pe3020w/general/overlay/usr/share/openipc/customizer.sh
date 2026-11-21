#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ak3918ev300_lite_heimvision-pe3020w-nor.tgz'
#
#
# Set wlan device: RTL8188FU on USB
#
fw_setenv wlandev rtl8188fu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# IR-cut: Majestic pulses irCutPin1 for night and irCutPin2 for day. On this
# board GPIO 42 swings the filter to night and GPIO 41 back to day, each pulse
# about 150 ms and driven back low (confirmed on the camera,
# OpenIPC/builder#234).
cli -s .nightMode.irCutPin1 42
cli -s .nightMode.irCutPin2 41
cli -s .video0.codec h264
#
# Day and night from the photocell on SAR-ADC1 AIN0, in mV: about 3000 in
# light, under 50 covered (OpenIPC/builder#234), so high is light. Night
# below 300, day again above 1500, switched automatically.
cli -s .nightMode.lightMonitor true
cli -s .nightMode.adcReadout true
cli -s .nightMode.adcInvert true
cli -s .nightMode.adcChannel 0
cli -s .nightMode.minThreshold 300
cli -s .nightMode.maxThreshold 1500

exit 0
