#!/bin/sh

GPIO=53   # BLUE led, t31_lite_cmcc-hdc-51-a6-v10
N=0

gpio clear ${GPIO} | logger -t gpio

while true ; do
    if [ "$N" -ge 30 ]; then
        logger -t qrscan "Recognition timeout exceeded, reboot camera and try again..."
        gpio set ${GPIO} | logger -t gpio
        exit 1
    fi
    timeout 1 wget -q -O /tmp/image.jpg http://127.0.0.1/image.jpg
    data=$(qrscan -p /tmp/image.jpg)
    if [[ -n "$data" ]] && $(echo "$data" | grep -q wlan); then
        fw_setenv $(echo $data | cut -d " " -f 1 | sed 's/=/ /')
        fw_setenv $(echo $data | cut -d " " -f 2 | sed 's/=/ /')
        logger -t qrscan "Recognition successfully, wlanssid and wlanpass is writed to env. Reboot required."
        curl --data-binary @/usr/lib/sounds/ready_48k.pcm http://localhost/play_audio
        for a in $(seq 10) ; do (gpio set ${GPIO} ; sleep 0.3 ; gpio clear ${GPIO} ; sleep 0.3 ) ; done | logger -t gpio
        reboot -f
    fi
    sleep 1
    N=$((N + 1))
done

