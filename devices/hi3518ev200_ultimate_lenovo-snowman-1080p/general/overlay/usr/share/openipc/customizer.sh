#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_ultimate_lenovo-snowman-1080p-nor.tgz'
fw_setenv sensor 'sc2035'
fw_setenv wlandev 'rtl8188eus-lenovo-snowman'
#
#
# Set custom majestic settings
#
cli -s .system.staticDir /var/www/majestic
cli -s .nightMode.enabled true
cli -s .nightMode.irCutPin1 33
cli -s .nightMode.irCutSingleInvert true
cli -s .nightMode.backlightPin 50
cli -s .ips.sensorConfig /etc/sensors/sc2035_i2c_1080p.ini
cli -s .audio.speakerPin 37

#

exit 0
