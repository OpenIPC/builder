#!/bin/sh

# Set custom upgrade url
fw_setenv upgrade 'https://github.com/OpenIPC/builder/releases/download/latest/ssc338q_waybeam_generic-nor.tgz'

# Send the stream to wfb-ng rather than the package's example address:
# S98wifibroadcast starts wfb_tx on the abstract unix socket rtp_local
# (-U rtp_local). Only what this build changes is set here; everything else
# stays the waybeam package's default. Runs at S30, before S95waybeam.
json_cli -s .outgoing.server '"unix://rtp_local"' -i /etc/waybeam.json
json_cli -s .outgoing.streamMode '"rtp"' -i /etc/waybeam.json
json_cli -s .video0.fps 60 -i /etc/waybeam.json
json_cli -s .video0.bitrate 8000 -i /etc/waybeam.json

exit 0
