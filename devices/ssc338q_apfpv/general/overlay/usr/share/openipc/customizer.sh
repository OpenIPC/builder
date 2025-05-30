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
cli -s .isp.exposure 10
cli -s .video0.fps 90
cli -s .video0.bitrate 8192
cli -s .video0.codec h265
cli -s .video0.rcMode cbr
cli -s .outgoing.enabled true
cli -s .outgoing.server udp://192.168.0.10:5600
