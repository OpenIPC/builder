#!/bin/sh
#
# LED control for Xiaomi MJSXJ03HL

show_help() {
    echo "Usage: $0 [-o <0|1>] [-b <0|1>]
    -o <0|1>   Switch state for orange LED.
    -b <0|1>   Switch state for blue LED."
    exit 0
}

led_control() {
    echo "Switching LED with GPIO${1} to state ${2}"
    if [ ! -d /sys/class/gpio/gpio${1}/ ]; then
	echo ${1} > /sys/class/gpio/export
	echo out > /sys/class/gpio/gpio${1}/direction
    fi
    echo ${2} > /sys/class/gpio/gpio${1}/value
}

if [ $# -eq 0 ]; then show_help; fi
while getopts o:b: flag; do
    case ${flag} in
	o)
	    [ ${OPTARG} -eq 0 -o ${OPTARG} -eq 1 ] || show_help
	    led_control 39 ${OPTARG}
	    ;;
	b)
	    [ ${OPTARG} -eq 0 -o ${OPTARG} -eq 1 ] || show_help
	    led_control 38 ${OPTARG}
	    ;;
	*)
	    show_help
	    ;;
    esac
done
