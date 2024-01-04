#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7102ca_lite-vstarcam-g8896wip-nor.tgz'
#
#
# Set custom majestic settings
#
#cli -s .system.webAdmin disabled
#cli -s .system.staticDir /var/www/majestic
#cli -s .nightMode.enabled true
#cli -s .nightMode.irSensorPin ??
#cli -s .nightMode.irCutPin1 ??
#cli -s .nightMode.irCutPin2 ??
#cli -s .nightMode.backlightPin ??
#cli -s .audio.speakerPin ??
#cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev rtl8189es-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# reset gpio - ?
# wifi gpio - ?
#
exit 0
