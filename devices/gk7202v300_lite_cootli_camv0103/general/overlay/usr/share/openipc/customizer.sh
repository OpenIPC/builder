#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Inside IPC_GK7202V300_G4-WR-BL_S38 board from XM
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7202v300_lite_cootli_camv0103-nor.tgz'
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev ssv6x5x-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# Set majestic settings
#
cli -s .nightMode.irCutPin1 56
cli -s .nightMode.irCutPin2 58
cli -s .nightMode.backlightPin 16
#cli -s .nightMode.lightMonitor true
cli -s .nightMode.minThreshold 2000
cli -s .nightMode.maxThreshold 17000
cli -s .audio.enabled true
cli -s .audio.outputEnabled true
cli -s .audio.speakerPin 51

exit 0
