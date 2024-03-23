#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518ev200_lite_switcam-hs303-v2-nor.tgz'
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188eus-switcam-hs303v2
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
# Set majestic settings
#
cli -s .system.staticDir /var/www/majestic

cli -s .isp.blkCnt 5
cli -s .isp.iqProfile /etc/sensors/iq/ov9732.ini

cli -s .nightMode.enabled true
cli -s .nightMode.irCutPin1 2
cli -s .nightmode.irSensorPin 62
cli -s .nightmode.irSensorPinInvert true
cli -s .nightMode.backlightPin 56

cli -s .audio.enabled true
cli -s .audio.volume 70
cli -s .audio.srate 8000
cli -s .audio.codec alaw
cli -s .audio.outputEnabled true
cli -s .audio.speakerPin 53
cli -s .audio.speakerPinInvert true

cli -s .rtsp.enabled true
cli -s .onvif.enabled false

cli -s .video0.fps 20
cli -s .video0.codec h264

cli -s .jpeg.enabled true

cli -s .mjpeg.size 640x360
cli -s .mjpeg.fps 5
cli -s .mjpeg.bitrate 2048

exit 0
