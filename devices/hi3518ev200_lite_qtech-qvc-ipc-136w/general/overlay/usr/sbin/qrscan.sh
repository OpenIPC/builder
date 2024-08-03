#!/bin/sh

n=0

gpio clear 1 | logger -t gpio  # RED led, hi3518ev200_lite_switcam-hs303-v3

while true ; do
    if [ "$n" -ge 30 ]; then
        logger -t qrscan "Recognition timeout exceeded, reboot camera and try again..."
        gpio set 1  | logger -t gpio
        exit 1
    fi
    timeout 1 wget -q -O /tmp/image.jpg http://127.0.0.1/image.jpg
    data=$(qrscan -p /tmp/image.jpg)
    if [[ -n "$data" ]]; then
        fw_setenv $(echo $data | cut -d " " -f 1 | sed 's/=/ /')
        fw_setenv $(echo $data | cut -d " " -f 2 | sed 's/=/ /')
        logger -t qrscan "Recognition successfully, wlanssid and wlanpass is writed to env. Reboot required."
        curl --data-binary @/usr/lib/sounds/ready_48k.pcm http://localhost/play_audio
        sleep 3
        reboot -f
    fi
    sleep 1
    n=$((n + 1))
done

