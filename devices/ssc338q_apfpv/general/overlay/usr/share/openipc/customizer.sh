#!/bin/sh
cli -s .isp.exposure 10
cli -s .video0.fps 90
cli -s .video0.bitrate 8192
cli -s .video0.codec h265
cli -s .video0.rcMode cbr
cli -s .outgoing.enabled true
cli -s .outgoing.server udp://192.168.0.10:5600
