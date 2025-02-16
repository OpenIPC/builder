#!/bin/sh

gpio=53   # RED led, t21_lite_chinamobile-hdc-51-a5-v12
n=0

echo 1 > /sys/class/gpio/gpio${gpio}/active_low
gpio set ${gpio} | logger -t gpio

while true ; do
    if [ "$n" -ge 30 ]; then
        logger -t qrscan "Recognition timeout exceeded, reboot camera and try again..."
        gpio clear ${gpio} | logger -t gpio
        exit 1
    fi
    timeout 1 wget -q -O /tmp/image.jpg http://127.0.0.1/image.jpg
    data=$(qrscan -p /tmp/image.jpg)
    if [[ -n "$data" ]] && $(echo "$data" | grep -q =); then
        fw_setenv $(echo $data | cut -d " " -f 1 | sed 's/=/ /')
        fw_setenv $(echo $data | cut -d " " -f 2 | sed 's/=/ /')
        fw_setenv $(echo $data | cut -d " " -f 3 | sed 's/=/ /')
        logger -t qrscan "Recognition successfully, wlanssid and wlanpass is writed to env. Reboot required."
        curl --data-binary @/usr/lib/sounds/ready_48k.pcm http://localhost/play_audio
        for a in $(seq 10) ; do (gpio set ${gpio} ; sleep 0.3 ; gpio clear ${gpio} ; sleep 0.3 ) ; done >/dev/null 2>&1
        reboot -f
    fi
    sleep 1
    n=$((n + 1))
done

