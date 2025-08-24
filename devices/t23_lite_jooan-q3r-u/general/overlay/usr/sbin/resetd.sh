#!/bin/sh

if [ -e /usr/share/openipc/gpio.conf ]; then
        . /usr/share/openipc/gpio.conf
fi


[ -z $button ] && echo "GPIO pin for resetd is not set" | logger -t resetd && exit

# Counter for button press until reset
count=0

# prepare the pin
if [ ! -d /sys/class/gpio/gpio${button} ]; then
	echo "${button}" > /sys/class/gpio/export
	echo "in" > /sys/class/gpio/gpio${button}/direction
fi

# continuously monitor current value of reset switch
while [ true ]; do
	if [ "$(cat /sys/class/gpio/gpio${button}/value)" -eq 1 ]; then
		count=0
	else
		count=$((count+1))
		# 20 counts =~ 5 seconds @ 0.25 sleep intervals
		if [ $count -eq 20 ]; then
			#echo 'SET WIFI' | logger -t resetd
			#fw_setenv wlanssid WIFI
			#fw_setenv wlanpass 12345678
			for a in $(seq 10) ; do (gpio toggle ${led1} ; sleep 0.3 ; gpio toggle ${led1} ; sleep 0.3) ; done >/dev/null 2>&1
			echo 'RESETTING FIRMWARE' | logger -t resetd
			firstboot
		fi
	fi
	# This interval uses 1% CPU. Less sleep = more CPU
	sleep 0.25
done
