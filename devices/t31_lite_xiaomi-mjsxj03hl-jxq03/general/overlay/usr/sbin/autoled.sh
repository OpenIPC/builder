#!/bin/sh
#
# Automatic LED control for Xiaomi MJSXJ03HL

streamerProcess="majestic"
serviceProcess="sysupgrade"
pollingInterval=1

show_help() {
    echo "Usage: $0 [-p process] [-s process] [-i value] [-h]
    -p process   Monitored streamer process (default = ${streamerProcess}).
    -s process   Monitored service process (default = ${serviceProcess}).
    -i value     Polling interval in seconds (default = ${pollingInterval}).
    -h           Show this help."
    exit 0
}

# override config values with command line arguments
while getopts H:L:i:h flag; do
    case ${flag} in
	p)
	    streamerProcess=${OPTARG}
	    ;;
	s)
	    serviceProcess=${OPTARG}
	    ;;
	i)
	    pollingInterval=${OPTARG}
	    ;;
	h | *)
	    show_help
	    ;;
    esac
done

echo "Streamer process: ${streamerProcess}"
echo "Service process: ${serviceProcess}"
echo "Polling interval: ${pollingInterval} sec"

led_state=0
/usr/sbin/led_control.sh -o 0 -b 0

while true; do
    if killall -q -0 $serviceProcess; then
	if [ $led_state -ne 3 ]; then
	    echo "$serviceProcess is running, turn white LED on"
	    /usr/sbin/led_control.sh -o 1 -b 1
	    led_state=3
	fi
    else
	if [ $led_state -ne 1 ] && ! killall -q -0 $streamerProcess; then
	    echo "$streamerProcess is not running, turn orange LED on"
	    /usr/sbin/led_control.sh -o 1 -b 0
	    led_state=1
	elif [ $led_state -ne 2 ] && killall -q -0 $streamerProcess; then
	    echo "$streamerProcess is running, turn blue LED on"
	    /usr/sbin/led_control.sh -o 0 -b 1
	    led_state=2
	fi
    fi
    sleep $pollingInterval
done
