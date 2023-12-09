#!/bin/sh
#
# Majestic settinfs for Xiaomi MJSXJ02HL
#
# nightMode:
#   enabled: true
#   irCutPin1: 70
#   irCutPin2: 68
#   backlightPin: 54

again_high_target=14000
again_low_target=2000
pollingInterval=5

show_help() {
    echo "Usage: $0 [-H value] [-L value] [-i value] [-h]
    -H value   Again high target (default = ${again_high_target}).
    -L value   Again low target (default = ${again_low_target}).
    -i value   Polling interval (default = ${pollingInterval}).
    -h         Show this help."
    exit 0
}

while getopts H:L:i:h flag; do
    case ${flag} in
        H) again_high_target=${OPTARG} ;;
        L) again_low_target=${OPTARG} ;;
        i) pollingInterval=${OPTARG} ;;
        h | *) show_help ;;
    esac
done

echo "...................."
echo "Watching at isp_again > ${again_high_target} to enable night mode"
echo "Watching at isp_again < ${again_low_target} to disable night mode"
echo "Polling interval: ${pollingInterval} sec"
echo "...................."

login=$(cat /etc/httpd.conf | grep cgi-bin | cut -d':' -f2)
pass=$(cat /etc/httpd.conf | grep cgi-bin | cut -d':' -f3)

while true; do
    metrics=$(curl -s http://localhost/metrics)
    isp_again=$(echo "${metrics}" | awk '/^isp_again/ {print $2}' | grep . || echo 0)
    night_enabled=$(echo "${metrics}" | awk '/^night_enabled/ {print $2}' | grep . || echo 0)

    if [ $night_enabled -ne 1 ] && [ $isp_again -gt $again_high_target ]; then
        curl -s -u $login:$pass http://localhost/night/on
        echo "Condition isp_again > ${again_high_target} was met (current value is ${isp_again}), turn on the night mode"
    elif [ $night_enabled -ne 0 ] && [ $isp_again -lt $again_low_target ]; then
        curl -s -u $login:$pass http://localhost/night/off
        echo "Condition isp_again < ${again_low_target} was met (current value is ${isp_again}), turn off the night mode"
    fi
    
    sleep $pollingInterval
done
