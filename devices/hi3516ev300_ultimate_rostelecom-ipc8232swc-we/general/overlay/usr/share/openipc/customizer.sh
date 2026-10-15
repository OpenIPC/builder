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
# The lens is this board's, not the sensor's, so its distortion correction is
# set here. 200 (crop view, centred) is what the stock firmware runs on this
# camera, read from its /proc/umap/vi; it straightens the wide lens's barrel
# and costs about a tenth of the width at the edges. It moves VPSS offline,
# which isp.blkCnt 6 above was measured to carry at 25 fps.
cli -s .isp.ldc 200
#
#
# The RTL8188FU is the camera's own radio, so it is named here. It stays
# beside the cable, not instead of it: with no wlanssid the wired port keeps
# DHCP and QR onboarding listens, and once a network is saved S40network
# keeps both up with the cable preferred (OpenIPC/firmware cable-primary
# networking; `fw_setenv netmode wifi` for WiFi alone).
fw_setenv wlandev rtl8188fu-generic
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678

exit 0
