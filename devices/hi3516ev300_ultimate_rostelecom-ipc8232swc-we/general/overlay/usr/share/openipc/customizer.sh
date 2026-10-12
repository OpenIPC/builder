#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# No totalmem, osmem or sensor: load_hisilicon and set_allocator read the
# DDR size from the device tree and default osmem to 32M, which gives the
# 96M MMZ this board streams with, and the SP2305 is autodetected (it reads
# as ov2735, which firmware aliases to the sp2305 profile).
#
# No `upgrade` URL: the -nor.tgz pinned here sent this NAND camera to the
# NOR package, because sysupgrade reads `upgrade` ahead of its own default.
# That default is <BUILD_PLATFORM>-<nor|nand>.tgz on builder, picked by the
# flash the camera has.
#
# Set custom majestic settings
#
cli -s .isp.blkCnt 6
cli -s .video0.codec h264
cli -s .nightMode.irCutPin1 63
cli -s .nightMode.irCutPin2 67
cli -s .nightMode.backlightPin 72
cli -s .nightMode.colorToGray true
cli -s .nightMode.lightMonitor false
cli -s .nightMode.monitorDelay 5
cli -s .nightMode.minThreshold 1500
cli -s .nightMode.maxThreshold 20000
cli -s .audio.enabled true
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 28
cli -s .audio.srate 48000
#
#
# No wlandev: S40network skips DHCP on eth0 whenever it is set and gives
# the wired port a static 192.168.2.10, so setting it here made a camera on
# Ethernet unreachable on its first boot. To use the RTL8188FU instead:
#fw_setenv wlandev rtl8188fu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
