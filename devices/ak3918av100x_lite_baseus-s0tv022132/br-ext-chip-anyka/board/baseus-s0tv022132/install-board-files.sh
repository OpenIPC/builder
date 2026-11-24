#!/bin/sh
set -eu

target=$1
board=$(dirname "$0")
modules=$target/lib/modules/4.4.282
install -m 644 "$board/files/majestic.yaml" "$target/etc/majestic.yaml"
install -m 644 "$board/files/sensor_sc5336.ko" "$modules/anyka/"
install -m 644 -t "$target/etc/sensor" "$board/files/isp_sc5336_mipi_2lane_av100_15fps_YuTong.conf"

for depmod in "$HOST_DIR/sbin/depmod" "$HOST_DIR/bin/depmod"; do
    if [ -x "$depmod" ]; then
        "$depmod" -b "$target" 4.4.282
        exit $?
    fi
done
echo 'Baseus: host depmod is missing' >&2
exit 1
