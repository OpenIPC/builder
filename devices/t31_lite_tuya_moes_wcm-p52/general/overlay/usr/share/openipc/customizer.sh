#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
# fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t31_lite_tuya_moes_wcm-p52-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .isp.blkCnt 1
cli -s .video0.codec h264
cli -s .nightMode.irCutPin1 57
cli -s .nightMode.irCutPin2 58
cli -s .nightMode.backlightPin 6
cli -s .nightMode.monitorDelay 5
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
cli -s .audio.speakerPinInvert true
cli -s .onvif.enabled false
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev atbm601x-t31-moes-wcm-p52
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set osmem and rmem
#
fw_setenv osmem 37M@0x0
fw_setenv rmem 27M@0x2500000
#
# Set motor and mmc
#
#fw_setenv gpio_mmc 61
fw_setenv ptz true
fw_setenv gpio_motors '54 52 53 64 63 62 61 51'
#
#
#adduser viewer -s /bin/false -D -H ; echo viewer:123456 | chpasswd
#
(sleep 3 ; reboot -f) &
#

exit 0
