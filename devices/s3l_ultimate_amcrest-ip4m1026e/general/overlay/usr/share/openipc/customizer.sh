#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/s3l_ultimate_amcrest-ip4m1026e-nor.tgz'
#
#
# The OV4689 is held in reset (GPIO 107) until its driver loads, so load_ambarella
# cannot find it by probing I2C. Name it instead.
#
fw_setenv sensor ov4689
#
#
# The Dahua U-Boot counts boots (one byte at flash 0x1a80000) and, on reading 5, boots its
# backup system from the stock backupker/backupfs instead. Stock clears the count after
# every good boot; OpenIPC doesn't. sysbackup=0 turns the counting and the backup boot off
# and leaves its TFTP upgrade path alone.
#
fw_setenv sysbackup 0
#
#
# Night mode: IR-cut on 113 (filter out) and 111 (filter in), IR LEDs on 5.
#
cli -s .nightMode.irCutPin1 113
cli -s .nightMode.irCutPin2 111
cli -s .nightMode.backlightPin 5
#
# Day/night from the light sensor on ADC channel 1. It reads higher in light (lit ~2900,
# covered 15-200), the other way round from what Majestic expects, hence adcInvert.
#
cli -s .nightMode.adcReadout true
cli -s .nightMode.adcChannel 1
cli -s .nightMode.adcInvert true
cli -s .nightMode.minThreshold 256
cli -s .nightMode.maxThreshold 672
cli -s .nightMode.lightMonitor true

exit 0
