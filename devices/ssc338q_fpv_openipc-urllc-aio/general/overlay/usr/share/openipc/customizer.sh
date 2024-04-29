#!/bin/sh

# Set custom upgrade url
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc338q_fpv_openipc-urllc-aio-nor.tgz'

# Set custom majestic settings
cli -s .video0.codec h265

exit 0
