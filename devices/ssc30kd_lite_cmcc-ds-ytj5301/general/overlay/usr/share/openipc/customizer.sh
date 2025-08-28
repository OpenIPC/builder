#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc30kd_lite_cmcc-ds-ytj5301-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .video0.codec h264
cli -s .nightMode.irCutPin1 23
cli -s .nightMode.irCutPin2 24
#cli -s .nightMode.backlightPin 59
cli -s .nightMode.monitorDelay 5
cli -s .osd.enabled true
cli -s .osd.template "OpenIPC | %F %T %Z"
cli -s .audio.enabled true
cli -s .audio.codec aac
cli -s .audio.srate 48000
cli -s .audio.volume 80
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
#cli -s .audio.speakerPin XX
#cli -s .audio.speakerPinInvert true
#
#
# Set wlan device and credentials if need
#
#fw_setenv wlandev rtl8188fu-ssc30kq-cmcc-ds-ytj5301
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set motor and mmc
#
#fw_setenv gpio_mmc XX
fw_setenv gpio_motors 59 60 8 9 111 112 113 114
#
#
#adduser viewer -s /bin/false -D -H ; echo viewer:123456 | chpasswd
#
(sleep 3 ; reboot -f) &
#

exit 0
