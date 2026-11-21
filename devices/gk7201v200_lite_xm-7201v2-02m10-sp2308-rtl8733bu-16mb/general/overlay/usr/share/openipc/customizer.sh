#!/bin/sh

# Set custom upgrade url
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7201v200_lite_xm-7201v2-02m10-sp2308-rtl8733bu-16mb-nor.tgz'

# Set memory allocation (64M physical RAM, 32M for Linux, 32M for MMZ/ISP)
fw_setenv totalmem 64M
fw_setenv osmem 32M

# Set sensor boot variable and Majestic ISP profile (SP2308, sold as OS02M10)
fw_setenv sensor sp2308
cli -s .isp.sensorConfig /etc/sensors/sp2308_i2c_1080p.ini

# Wireless driver configuration (configured via Web UI / CLI by the user)
fw_setenv wlandev rtl8733bu-gk7201v200-xm

# IR-cut: GPIO15 drives the filter out (night), GPIO13 back in (day). The pads
# are switched to GPIO by /etc/init.d/S71irmux. The IR LEDs are switched by the
# board's own light sensor, which no SoC pin reads: day and night follow the
# picture instead.
cli -s .nightMode.irCutPin1 15
cli -s .nightMode.irCutPin2 13
cli -s .nightMode.colorToGray true
cli -s .nightMode.lightMonitor true

# Microphone only: no speaker is confirmed on this board
cli -s .audio.enabled true
cli -s .audio.srate 8000
cli -s .audio.codec alaw
cli -s .audio.volume 50
cli -s .audio.gain 20
cli -s .audio.outputEnabled false
cli -s .onvif.enabled true

exit 0
