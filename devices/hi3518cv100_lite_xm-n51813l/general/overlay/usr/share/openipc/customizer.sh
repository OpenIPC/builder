#!/bin/sh
#
# Perform basic settings on a known IP camera
#
# XiongMai JZC-N51813L: hi3518cv100 (HiSilicon Hi3518C V100), 128M RAM, 16M NOR,
# an 18x zoom block whose own MCU sits on UART0 (9600 8N1) and both runs the
# lens (Sony VISCA, camera address 1) and configures the Aptina AR0130 sensor.
# The SoC sees nothing on I2C, so the sensor is named, and no frame reaches VI
# until /etc/init.d/S90lens-mcu has sent the MCU its "init camera" frame.
#
#
# Set sensor. Linux needs mem=64M on this board: at 32M majestic starves.
#
fw_setenv sensor ar0130
fw_setenv osmem 64M
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/hi3518cv100_lite_xm-n51813l-nor.tgz'
#
#
# Zoom and focus: majestic-af's `visca` actuator on the MCU's UART. Focus is
# the MCU's own (it refocuses after every zoom), so the plugin books no pass
# of its own.
#
cli -s .ptz.enabled true
cli -s .ptz.actuator visca
cli -s .ptz.port /dev/ttyAMA0
cli -s .ptz.baud 9600
#
#
# The WebUI's PTZ pad: majestic drives the lens, the WebUI asks /ptz. A
# pan/tilt head goes in ptz.head / ptz.headPort (its own tty, or
# tcp://<ip>:<port> for a serial gateway), since the lens holds ptz.port.
# ptz_caps stays unset on purpose: unlike 'zoom focus' on the zoom-only
# blocks, it lets the pad take its axes from majestic's verbs= -- zoom and
# focus for the block alone, pan and tilt too once a head is configured.
fw_setenv ptz_control visca
#
#
# The MCU runs the sensor's exposure and gain; the ISP's analog and digital
# gain would only be numbers it cannot apply, so they stay at 1x and its own
# digital gain is all auto-exposure moves. The image tuning that goes with it
# (black level, AWB, colour matrices, NR by the MCU's reported gain) is the
# board's /etc/sensors/iq/ar0130.ini.
#
cli -s .isp.aGain 1
cli -s .isp.dGain 1
#
#
# Orientation as the stock firmware shows it: Sofia captures with VI mirror
# and flip on, so the block reads the other way up from the raw sensor.
# That puts the two junk lines the MCU leaves on the AR0130 frame at the
# bottom (rows 958-959); the crop cuts them off.
#
cli -s .image.mirror true
cli -s .image.flip true
cli -s .video0.crop 0x0x1280x958
#
#
# Encoder as the stock firmware runs it on this block: VBR, 2560 kbps, a
# keyframe every 2 s (GOP 50), max QP 45. majestic's default for 1280x958
# was CBR at half that rate with a GOP of 1 s.
#
cli -s .video0.rcMode vbr
cli -s .video0.bitrate 2560
cli -s .video0.gopSize 2
#
#
# The MCU owns the console UART, so getty must not sit on it reading the
# MCU's bytes. The edit lands in the overlay; an upgrade that wipes the
# overlay also wipes /etc/custom.ok, so this script runs again and the
# camera heals itself.
#
sed -i '/getty/d' /etc/inittab
#
#
# Reboot so the environment and the inittab edit take effect.
#
(sleep 3 ; reboot -f) &
#

exit 0
