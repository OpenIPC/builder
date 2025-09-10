#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# Set custom majestic settings
#
cli -s .isp.blkCnt 4
#cli -s .audio.speakerPin 7
cli -s .nightMode.irCutPin1 122
cli -s .nightMode.irCutPin2 123
cli -s .nightMode.backlightPin 119
cli -s .video0.codec h265
cli -s .video0.bitrate: 4000
cli -s .video0.rcMode: avbr
cli -s .video0.profile: high
cli -s .video0.gopSize: 5
cli -s .video0.gopMode: smart
#cli -s .onvif.enabled: true
cli -s .osd.enabled true
cli -s .osd.size: 0.8
cli -s .osd.template "%d.%m.%Y %H:%M:%S"
#cli -s .audio.enabled true
#cli -s .audio.codec aac
#cli -s .audio.srate 48000
#cli -s .audio.volume 95
#cli -s .audio.gain 25
#
# Set osmem and rmem
#
fw_setenv osmem 48M
fw_setenv rmem 65M@0x3000000
#
exit 0


