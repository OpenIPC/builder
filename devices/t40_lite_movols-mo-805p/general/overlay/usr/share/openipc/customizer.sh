#!/bin/sh
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t40_lite_movols-mo-805p-nor.tgz'
#
# Set custom majestic settings
#
cli -s .isp.blkCnt 3
#
cli -s .video0.codec h265
cli -s .video0.size 2560x1440
cli -s .video0.fps 20
cli -s .video0.rcMode avbr
cli -s .video0.bitrate 768
cli -s .video0.gopSize 6
cli -s .video0.gopMode smart
#
cli -s .video1.enabled true
cli -s .video1.codec h264
cli -s .video1.profile high
cli -s .video1.size 640x360
cli -s .video1.fps 8
cli -s .video1.rcMode avbr
cli -s .video1.adjustBitrate false
cli -s .video1.gopSize 3
cli -s .video1.gopMode smart
#
cli -s .audio.enabled true
cli -s .audio.codec ulaw
cli -s .rtsp.audioCodec ulaw
#
cli -s .nightMode.irCutPin1 122
cli -s .nightMode.irCutPin2 123
cli -s .nightMode.backlightPin 119
cli -s .nightMode.whiteLightPin 118
#
# Set osmem and rmem
#
fw_setenv osmem 48M
fw_setenv rmem 80M@0x3000000
#
exit 0


