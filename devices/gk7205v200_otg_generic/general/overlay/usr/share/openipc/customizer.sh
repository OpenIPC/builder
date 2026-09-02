#!/bin/sh
#
# Perform basic settings on a known IP camera
#
#
# Set custom upgrade url
#
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/gk7205v200_otg_generic-nor.tgz'
#
#
# Reboot so the environment and the inittab edit take effect.
#
(sleep 3 ; reboot -f) &
#

exit 0
