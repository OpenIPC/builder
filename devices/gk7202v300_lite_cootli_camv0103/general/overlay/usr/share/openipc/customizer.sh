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

exit 0
