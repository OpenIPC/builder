#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/xm530_lite_misecu-xm-63-ai-50w-nor.tgz'
#
# Set wlan device, its PDN gpio and credentials if need
#
fw_setenv wlandev atbm603x-xm530
fw_setenv wifipdn 96
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# The XM550 has 128 MB, but the stock environment boots with the XM530's
# mem=35M: 93 MB of media zone, of which the pipeline uses about 31. With the
# streams below (5 MP main, 640x360 sub) the owner measured, over several days
# (OpenIPC/firmware#2853), 31.3 MB of a 56 MB zone and 49 MB of Linux's 68 in
# use; 64 MB for Linux was too tight there. set_allocator rewrites mem= in
# bootargs and osmem together; the reboot below applies it.
#
set_allocator xm 72
#
# The sensor's full 5 MP, and the sub-stream the split above was measured with
#
cli -s .video0.size 2592x1944
cli -s .video0.fps 15
cli -s .video0.rcMode avbr
cli -s .video1.enabled true
cli -s .video1.size 640x360
cli -s .video1.fps 12
#
# Night mode, confirmed on this camera in OpenIPC/firmware#2853. The board
# has no light sensor (the stock Isp.json sets InfraredIO 255), so it
# switches on exposure: night at isp_exposureismax, day under 6x gain, well
# below the 15.5x it sits at with the IR LEDs on.
#
cli -s .nightMode.irCutPin1 1
cli -s .nightMode.irCutPin2 2
cli -s .nightMode.backlightPin 39
cli -s .nightMode.whiteLightPin 41
cli -s .nightMode.switchBy exposure
cli -s .nightMode.autoDayGain 6
#
(sleep 3 ; reboot -f) &

exit 0
