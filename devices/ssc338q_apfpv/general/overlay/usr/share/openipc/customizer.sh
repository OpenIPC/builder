#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/openipc.ssc338q-nor-apfpv.tgz'
#
#
# Set custom majestic settings
#
cli -s .isp.exposure 15
cli -s .video0.fps 60
cli -s .video0.bitrate 10000
cli -s .video0.codec h265
cli -s .video0.rcMode avbr
cli -s .audio.codec pcm
cli -s .outgoing.enabled true
cli -s .outgoing.server udp://192.168.0.10:5600
cli -s .records.split 5
cli -s .records.notime true
