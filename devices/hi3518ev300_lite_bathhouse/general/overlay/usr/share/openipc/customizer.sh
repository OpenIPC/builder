#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
#fw_setenv upgrade 'https://natrium.zftlab.org/firmware/elsar/openipc.gk7205v200-nor-ultimate.tgz'
#
#
# Set custom majestic settings
#
#cli -s .system.webAdmin disabled
#cli -s .system.staticDir /var/www/majestic
#cli -s .isp.sensorConfig /etc/sensors/bt656_ahd_1920x1080_25fps.ini
#cli -s .nightMode.lightMonitor true
#cli -s .nightMode.minThreshold 2000
#cli -s .nightMode.maxThreshold 14000
#cli -s .audio.speakerPin 55
cli -s .video0.codec h264
cli -s .audio.enabled true
cli -s .audio.codec opus
cli -s .audio.volume 30
cli -s .audio.srate 48000
#
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev unknown
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#

exit 0

