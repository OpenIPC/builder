#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/t23_lite_vstarcam-c8622-nor.tgz'
#
# AIC8800DC USB wifi
#
fw_setenv wlandev aic8800-t23-vstarcam-c8622
#
#
# Set custom majestic settings
#
# The IR-cut filter is not GPIO-driven on this board: it hangs off the fifth
# channel of the GC6153F stepper chip, and the gc6153 majestic-af backend
# swings it by watching nightMode.backlightPin. So no irCutPin1/irCutPin2.
#
cli -s .video0.codec h264
cli -s .nightMode.backlightPin 61
cli -s .nightMode.whiteLightPin 50
cli -s .nightMode.monitorDelay 5
cli -s .nightMode.lightMonitor true
cli -s .nightMode.minThreshold 10
cli -s .nightMode.maxThreshold 100
cli -s .osd.enabled true
cli -s .osd.template "OpenIPC | %F %T %Z"
cli -s .audio.enabled true
cli -s .audio.codec aac
cli -s .audio.srate 48000
cli -s .audio.volume 95
cli -s .audio.gain 25
cli -s .audio.outputEnabled true
cli -s .audio.outputVolume 80
cli -s .audio.speakerPin 63
#
#
# Pan/tilt via the gc6153 majestic-af backend (GC6153F on bit-banged i2c)
#
cli -s .ptz.enabled true
cli -s .ptz.actuator gc6153
# The webui's PTZ switch has no gc6153 token; gpiostep takes the plugin path.
fw_setenv ptz_control gpiostep
fw_setenv ptz_caps "pan tilt"
#
#
# Set sensor (this unit is resoldered to ethernet; wifi stays the default)
#
fw_setenv sensor gc1084
#fw_setenv wlanssid Router
#fw_setenv wlanpass 12345678
#
#
# Set osmem and rmem
#
fw_setenv osmem 45M@0x0
fw_setenv rmem 19M@0x2D00000
#
#
#adduser viewer -s /bin/false -D -H ; echo viewer:12345678 | chpasswd
#
(sleep 3 ; reboot -f) &

exit 0
