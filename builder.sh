#!/bin/bash
#
# OpenIPC | version 2023.11.30

# Autoupdate BUILDER repo
# Remove old building folder (for full rebuild)
# Download OpenIPC repo
# Copy files from Device Overlay
# Build Firmware
# Copy Kernel and Rootfs to Archive
# Copy Kernel and Rootfs to TFTP server


RELEASE=""
DEVICE="$1"

TFTP_STORAGE="root@172.17.32.17:/mnt/bigger-2tb/Rotator/TFTP"

BUILDER_DIR=$(pwd)
FIRMWARE_DIR="${BUILDER_DIR}/openipc"
TIMESTAMP=$(date +"%Y%m%d%H%M")
VERSION=$(stat -c"%Y" $0)

echo_c() {
    # 30 grey, 31 red, 32 green, 33 yellow, 34 blue, 35 magenta, 36 cyan, 37 white
    t="\e[1;$1m$2\e[0m" || t="$2"
    echo -e "$t"
}

copy_to_archive() {
    echo_c 32 "Copying files to local archive"
    mkdir -p "${BUILDER_DIR}/archive/${DEVICE}/${TIMESTAMP}"
    cp -a \
        ${FIRMWARE_DIR}/output/images/rootfs.squashfs.* \
        ${FIRMWARE_DIR}/output/images/uImage.* \
        ${FIRMWARE_DIR}/output/images/*.tar \
        ${FIRMWARE_DIR}/output/images/openipc.*.tgz \
        ${BUILDER_DIR}/archive/${DEVICE}/${TIMESTAMP}

    if [ -f "${FIRMWARE_DIR}/output/images/autoupdate-kernel.img" ] ; then
        cp -a ${FIRMWARE_DIR}/output/images/autoupdate* ${BUILDER_DIR}/archive/${DEVICE}/${TIMESTAMP}
    fi

    echo_c 35 "\nAssembled firmware available in:"
    tree -C "${BUILDER_DIR}/archive/${DEVICE}/${TIMESTAMP}"
}

copy_to_tftp() {
    echo_c 32 "\nCopying files to a TFTP server using SCP protocol"
    scp -r \
        ${FIRMWARE_DIR}/output/images/rootfs.squashfs.* \
        ${FIRMWARE_DIR}/output/images/uImage.* \
        ${FIRMWARE_DIR}/output/images/openipc.*.tgz \
        ${TFTP_STORAGE}

    if [ -f "${FIRMWARE_DIR}/output/images/autoupdate-kernel.img" ] ; then
        scp -r ${FIRMWARE_DIR}/output/images/autoupdate* ${TFTP_STORAGE}
    fi
}

select_device() {
    AVAILABLE_DEVICES=$(ls -1 ${BUILDER_DIR}/devices | grep '_')
    cmd="whiptail --title \"Available devices\" --menu \"Please select a device from the list below:\" 25 78 16"
    for p in $AVAILABLE_DEVICES; do cmd="${cmd} \"$p\" \"\""; done
    DEVICE=$(eval "${cmd} 3>&1 1>&2 2>&3")
    if [ $? != 0 ]; then
        echo_c 31 "Cancelled."
        exit 1
    fi
}


echo_c 37 "Experimental system for building OpenIPC firmware for known devices"
echo_c 30 "https://openipc.org/"
echo_c 30 "Version: ${VERSION}"

while [ -z "${DEVICE}" ]; do select_device; done

echo_c 31 "\nStarting a device for ${DEVICE}"
tree -C ${BUILDER_DIR}/devices/${DEVICE}

sleep 3

echo_c 33 "\nUpdating Builder"
git pull

rm -rf openipc  # Weed work with this command
if [ ! -d "$FIRMWARE_DIR" ]; then
    echo_c 33 "\nDownloading Firmware"
    git clone --depth=1 https://github.com/OpenIPC/firmware.git "$FIRMWARE_DIR"
    cd "$FIRMWARE_DIR"
else
    echo_c 33 "\nUpdating Firmware"
    cd "$FIRMWARE_DIR"
    # git reset HEAD --hard
    # git pull --rebase
fi

echo_c 33 "\nCopying device files"
cp -afv ${BUILDER_DIR}/devices/${DEVICE}/*  ${FIRMWARE_DIR}

echo_c 33 "\nBuilding the device"
./building.sh ${DEVICE}

copy_to_archive
# copy_to_tftp
echo_c 35 "\nDone"
cd "$BUILDER_DIR"
