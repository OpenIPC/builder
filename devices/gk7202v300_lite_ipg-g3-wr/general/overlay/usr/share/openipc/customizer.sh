#!/bin/sh

fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7202v300_lite_ipg-g3-wr-nor.tgz'

fw_setenv wlandev atbm603x-generic-usb
fw_setenv sensor jxh63_i2c_720p

exit 0
