#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set SoC and sensor. The SC2235 is wired to the DVP pads, which
# load_hisilicon only routes when sensor_dvp=1.
#
fw_setenv soc hi3516ev200
fw_setenv sensor sc2235
fw_setenv sensor_dvp 1
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3516ev200_lite_imou-cue2-c22en-nor.tgz'
#
# Set custom majestic settings
#
cli -s .isp.sensorConfig /etc/sensors/sc2235_i2c_dc_1080p.ini
cli -s .isp.iqProfile /etc/sensors/iq/sc2235.ini
cli -s .isp.slowShutter low
# The sensor is mounted upside down
cli -s .image.mirror true
cli -s .image.flip true
cli -s .video0.codec h264
cli -s .video0.fps 20
cli -s .video1.enabled true
cli -s .video1.size 640x360
cli -s .video1.fps 10
cli -s .nightMode.enabled true
cli -s .nightMode.colorToGray true
cli -s .nightMode.irCutPin1 55
cli -s .nightMode.irCutSingleInvert true
cli -s .nightMode.backlightPin 39
# No light sensor wired: switch on the ISP's exposure (software sensor)
cli -s .nightMode.lightMonitor true
cli -s .nightMode.monitorDelay 20
cli -s .nightMode.maxThreshold 12000
cli -s .nightMode.minThreshold 4000
cli -s .nightMode.overrideDrc 120
cli -s .audio.enabled true
cli -s .audio.codec opus
cli -s .audio.srate 8000
cli -s .audio.volume 30
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 53
cli -s .rtsp.backchannel true
#
# Set wlan device
#
fw_setenv wlandev rtl8188fu-hi3516ev200-imou-cue2

exit 0
