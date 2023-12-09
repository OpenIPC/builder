#!/bin/sh
#
# Automatic LED control for Xiaomi MJSXJ02HL

streamerProcess="majestic"
serviceProcess="sysupgrade"
pollingInterval=1

show_help() {
    echo "Usage: $0 [-p process] [-s process] [-i value] [-h]
    -p process   Name of the monitored streamer process (default = ${streamerProcess}).
    -s process   Name of the monitored service process (default = ${serviceProcess}).
    -i value     Polling interval in seconds (default = ${pollingInterval}).
    -h           Show this help."
    exit 0
}

# override config values with command line arguments
while getopts H:L:i:h flag; do
    case ${flag} in
        p) streamerProcess=${OPTARG} ;;
        s) serviceProcess=${OPTARG} ;;
        i) pollingInterval=${OPTARG} ;;
        h | *) show_help ;;
    esac
done

echo "...................."
echo "Name of the monitored streamer process: ${streamerProcess}"
echo "Name of the monitored service process: ${serviceProcess}"
echo "Polling interval: ${pollingInterval} sec"
echo "...................."

led_state=0
/usr/sbin/led_control.sh -o 0 -b 0
echo "...................."

while true; do
    if killall -q -0 $serviceProcess; then
        if [ $led_state -ne 3 ]; then
            echo "Process $serviceProcess is running, turn on the white LED"
            /usr/sbin/led_control.sh -o 1 -b 1
            led_state=3
            echo "...................."
        fi
    else
        if [ $led_state -ne 1 ] && ! killall -q -0 $streamerProcess; then
            echo "Process $streamerProcess is not running, turn on the orange LED"
            /usr/sbin/led_control.sh -o 1 -b 0
            led_state=1
            echo "...................."
        elif [ $led_state -ne 2 ] && killall -q -0 $streamerProcess; then
            echo "Process $streamerProcess is running, turn on the blue LED"
            /usr/sbin/led_control.sh -o 0 -b 1
            led_state=2
            echo "...................."
        fi
    fi
    sleep $pollingInterval
done
