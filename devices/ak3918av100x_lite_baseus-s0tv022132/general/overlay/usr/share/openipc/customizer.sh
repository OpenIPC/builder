#!/bin/sh

fw_printenv >/dev/null 2>&1 || exit 1

sensor=$(fw_printenv -n sensor 2>/dev/null)
ptz_control=$(fw_printenv -n ptz_control 2>/dev/null)
settings=$(mktemp /tmp/baseus-env.XXXXXX) || exit 1
trap 'rm -f "$settings"' EXIT

{
    [ -n "$(fw_printenv -n wlandev 2>/dev/null)" ] || echo 'wlandev baseus-aic8800'
    if [ -z "$sensor" ] || [ "$sensor" = unknown ]; then
        echo 'sensor sc5336'
    fi
    if [ -z "$ptz_control" ] || [ "$ptz_control" = gpio ]; then
        [ -n "$ptz_control" ] || echo 'ptz_control gpio'
        [ -n "$(fw_printenv -n ptz_caps 2>/dev/null)" ] || echo 'ptz_caps pan tilt'
        if [ -z "$(fw_printenv -n ptz_gpio 2>/dev/null)" ] &&
           [ -z "$(fw_printenv -n gpio_motors 2>/dev/null)" ]; then
            echo 'ptz_gpio 65 66 58 67 68 69 2 56'
        fi
    fi
} > "$settings"
[ ! -s "$settings" ] || fw_setenv -s "$settings"
