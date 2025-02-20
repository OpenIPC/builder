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

DEVICE="$1"
BUILDER_DIR=$(pwd)
FIRMWARE_DIR="${BUILDER_DIR}/openipc"
TIMESTAMP=$(date +"%Y%m%d%H%M")
VERSION=$(stat -c"%Y" $0)

echo_c() {
    # 30 grey, 31 red, 32 green, 33 yellow, 34 blue, 35 magenta, 36 cyan, 37 white
    t="\e[1;$1m$2\e[0m" || t="$2"
    echo -e "$t"
}

autoup_rootfs() {
    DT=$(date +"%y.%m.%d")
    OPENIPC_VER=$(echo OpenIPC v${DT:0:1}.${DT:1})
    SOC=$(echo ${DEVICE} | cut -d_ -f1)

    echo_c 34 "\nDownloading u-boot created by OpenIPC"
    curl --location --output ./output/images/u-boot-${SOC}-universal.bin \
        https://github.com/OpenIPC/firmware/releases/download/latest/u-boot-${SOC}-universal.bin

    echo_c 34 "\nMaking autoupdate u-boot image"
    ./output/host/bin/mkimage -A arm -O linux -T firmware -n "$OPENIPC_VER" \
        -a 0x0 -e 0x50000 -d ./output/images/u-boot-${SOC}-universal.bin \
        ./output/images/autoupdate-uboot.img

    echo_c 34 "\nMaking autoupdate kernel image"
    ./output/host/bin/mkimage -A arm -O linux -T kernel -C none -n "$OPENIPC_VER" \
        -a 0x50000 -e 0x250000 -d ./output/images/uImage.${SOC} \
        ./output/images/autoupdate-kernel.img

    echo_c 34 "\nMaking autoupdate rootfs image"
    ./output/host/bin/mkimage -A arm -O linux -T filesystem -n "$OPENIPC_VER" \
        -a 0x250000 -e 0x750000 -d ./output/images/rootfs.squashfs.${SOC} \
        ./output/images/autoupdate-rootfs.img
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

    if [ -f "${FIRMWARE_DIR}/output/images/autoupdate-kernel.img" ]; then
        cp -a ${FIRMWARE_DIR}/output/images/autoupdate* ${BUILDER_DIR}/archive/${DEVICE}/${TIMESTAMP}
    fi

    echo_c 35 "\nAssembled firmware available in:"
    tree -C "${BUILDER_DIR}/archive/${DEVICE}/${TIMESTAMP}"

    if $(echo ${DEVICE} | grep -q hi3518ev200_lite); then
        autoup_rootfs
    fi
}

copy_to_tftp() {
    echo_c 32 "\nCopying files to a TFTP server using SCP protocol"
    scp -r \
        ${FIRMWARE_DIR}/output/images/rootfs.squashfs.* \
        ${FIRMWARE_DIR}/output/images/uImage.* \
        ${FIRMWARE_DIR}/output/images/openipc.*.tgz \
        ${TFTP_STORAGE}

    if [ -f "${FIRMWARE_DIR}/output/images/autoupdate-kernel.img" ]; then
        scp -r ${FIRMWARE_DIR}/output/images/autoupdate* ${TFTP_STORAGE}
    fi
}

select_device() {
    AVAILABLE_DEVICES=$(find common devices -name *_defconfig | sort | cut -d/ -f5)
    cmd="whiptail --title \"Available devices\" --menu \"Please select a device from the list below:\" 20 70 12"
    for p in ${AVAILABLE_DEVICES//_defconfig}; do cmd="${cmd} \"$p\" \"\""; done
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
ITEM=$(find common devices -name ${DEVICE}_defconfig | cut -d/ -f1,2)
tree -C "${ITEM}"

sleep 3

echo_c 33 "\nUpdating Builder"
git pull

#rm -rf openipc
if [ ! -d "$FIRMWARE_DIR" ]; then
    echo_c 33 "\nDownloading Firmware"
#    git clone --depth=1 https://github.com/OpenIPC/firmware.git "$FIRMWARE_DIR"
    cd "$FIRMWARE_DIR"
#    rm -rf output
else
    echo_c 33 "\nUpdating Firmware"
    cd "$FIRMWARE_DIR"
    # git reset HEAD --hard
    # git pull --rebase
fi

echo_c 33 "\nCopying device files"
cp -afv ${BUILDER_DIR}/${ITEM}/* ${FIRMWARE_DIR}

echo_c 33 "\nBuilding the device"
make BOARD=${DEVICE}

copy_to_archive
echo_c 35 "\nDone"
cd "$BUILDER_DIR"
