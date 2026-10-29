#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t23_lite_litokam-p1t-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .nightMode.irCutPin1 16
cli -s .nightMode.irCutPin2 17
cli -s .nightMode.backlightPin 50
cli -s .nightMode.monitorDelay 5
cli -s .nightMode.lightMonitor true
cli -s .nightMode.minThreshold 10
cli -s .nightMode.maxThreshold 100
cli -s .osd.enabled true
cli -s .osd.template "OpenIPC | %F %T %Z"
cli -s .audio.enabled true
cli -s .audio.codec aac
cli -s .audio.srate 48000
cli -s .audio.volume 95
cli -s .audio.gain 25
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 7
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm601x-t23-litokam-p1t
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set pan/tilt stage
#
# 4 pan coils then 4 tilt coils, as the gpio-motors shim expects
fw_setenv ptz_gpio '54 52 53 64 61 62 63 51'
# 3982/796 are the full travel of each axis; 1991/398 is the midpoint of each,
# which is where homing leaves the stage
fw_setenv ptz_pan_max 3982
fw_setenv ptz_tilt_max 796
fw_setenv ptz_home_x 1991
fw_setenv ptz_home_y 398
#
#
# Set mmc
#
fw_setenv gpio_mmc 49
#
#
# Set osmem and rmem
#
fw_setenv osmem 45M@0x0
fw_setenv rmem 19M@0x2D00000
#
#
#adduser viewer -s /bin/false -D -H ; echo viewer:123456 | chpasswd
#
(sleep 3 ; reboot -f) &
#

exit 0
