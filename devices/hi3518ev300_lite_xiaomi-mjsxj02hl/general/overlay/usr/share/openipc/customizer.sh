#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev300_lite_xiaomi-mjsxj02hl-nor.tgz'
#
#
# Set custom majestic settings
#
cli -s .isp.iqProfile /etc/sensors/iq/f23.ini
cli -s .nightMode.irCutPin1 70
cli -s .nightMode.irCutPin2 68
cli -s .nightMode.backlightPin 54
cli -s .audio.speakerPin 55
cli -s .video0.codec h264
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8189fs-mjsxj02hl
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set osmem and rmem
#
fw_setenv bootargs 'mem=\${osmem} console=ttyAMA0,115200 panic=20 rootfstype=squashfs root=/dev/mtdblock3 init=/init mtdparts=\${mtdparts} mmz_allocator=hisi'
fw_setenv osmem 35M
#
exit 0
