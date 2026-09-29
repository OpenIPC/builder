#!/bin/sh

# Set custom upgrade url
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7201v200_lite_xm-7205-rtl8733bu-16mb-nor.tgz'

# Set memory allocation (64M physical RAM, 32M for Linux, 32M for MMZ/ISP)
fw_setenv totalmem 64M
fw_setenv osmem 32M

# Set sensor boot variable and Majestic ISP profile
fw_setenv sensor sc2336
cli -s .isp.sensorConfig /etc/sensors/sc2336_i2c_1080p.ini

# Wireless driver configuration (configured via Web UI / CLI by the user)
fw_setenv wlandev rtl8733bu-gk7201v200-xm

# Set custom majestic settings
cli -s .nightMode.irCut off
cli -s .audio.enabled true
cli -s .audio.volume 50
cli -s .audio.srate 32000
cli -s .audio.codec aac
cli -s .onvif.enabled true

exit 0
