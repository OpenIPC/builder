#!/bin/sh
#
# 360 D706 / D816_MAIN_v05 / Ingenic T20 / NOR 16M
# Perform basic settings on a known IP camera

# Sensor: first build uses gc2023.
# If gc2033 build, change this to gc2033.
fw_setenv sensor gc2023

# RTL8189FS / RTL8189FTV SDIO
fw_setenv wlandev rtl8189fs-generic

# Set custom majestic settings
# Basic video
cli -s .nightMode.irCutPin1 25
cli -s .nightMode.irCutPin2 26
cli -s .nightMode.backlightPin 49
cli -s .video0.codec h264
cli -s .audio.speakerPin 63

# Set wlan device and credentials if need

# D706 has no usable Ethernet PHY
fw_setenv extras nogmac
# Set osmem and rmem
# Keep memory layout close to the current working OpenIPC image
fw_setenv osmem 40M
fw_setenv rmem 24M@0x2800000

# Wi-Fi credentials are set later on device:
#fw_setenv wlanssid 'your_ssid'
#fw_setenv wlanpass 'your_password'
#
exit 0
