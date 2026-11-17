#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# Heimvision HM202, also sold as HM202A and as Heimlink HM202 (vendor firmware
# EYEPLUS eyeplus_ipc_ms_002): SSC325, GalaxyCore GC2063 (ID 0x2053, driven as
# gc2053), 8 MB NOR, LB-Link BL-M8188FU3 USB WiFi, pan/tilt steppers on a
# 74HC595, speaker and microphone, reset button.
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc325_lite_heimvision-hm202-nor.tgz'
#
#
# Set wlan device and credentials if need
#
fw_setenv wlandev rtl8188fu-heimvision-hm202
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set custom majestic settings
#
# The sensor sits upside down for a camera standing on its foot.
cli -s .image.mirror true
cli -s .image.flip true
# The WebUI's pan/tilt pad reads mirror, flip and rotate, and refuses every
# move while one of them is missing; this majestic has no rotate of its own.
cli -s .image.rotate 0
# IR-cut: a pulse on 78 takes the filter out, on 79 puts it back. IR LEDs on 44.
cli -s .nightMode.irCutPin1 78
cli -s .nightMode.irCutPin2 79
cli -s .nightMode.backlightPin 44
cli -s .nightMode.lightMonitor true
# The exposure-based trigger never fires here: the ISP never reports its
# exposure as maxed (isp_exposureismax stays 0 at 99 % and 64x gain in the
# dark). Switch on gain instead; 64x is the most this sensor gives.
cli -s .nightMode.autoNightGain 32
cli -s .audio.speakerPin 62
# Pan/tilt through majestic-af's gpiostep actuator (/ptz, ONVIF, WebUI).
cli -s .ptz.enabled true
cli -s .ptz.actuator gpiostep
fw_setenv ptz_control gpiostep
fw_setenv ptz_caps 'pan tilt'

exit 0
