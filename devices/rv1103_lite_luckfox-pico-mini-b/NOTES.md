# Luckfox Pico Mini B

Test profile for RV1103, SC3336, SPI NAND and a directly attached RTL8812AU USB
adapter. Hardware validation of this exact profile is pending.

The kernel image target is `rv1103g-luckfox-pico-mini-b-usb-host.img`, introduced
by OpenIPC/linux #68. It inherits the Mini NAND/camera configuration and disabled
Ethernet. The old Pico Plus host patch and `S22usbhost` PHY override are not used.
The NAND partition command line follows the existing RV1103 NAND test image.
The test artifacts include a separate `zboot.img` and a UBI rootfs image. Ensure
the booted kernel/DTB is updated as well as the rootfs; a rootfs-only update does
not test the new Mini B DTS. The packaged `kernel` UBI volume and the separate
`boot` partition are distinct in this layout.

Prerequisites before building against upstream repositories:

- OpenIPC/linux #68: Mini B USB host DTS.
- OpenIPC/realtek-wlan #10: Linux 5.10 compatibility on `rtl8812au_fpv`.
This profile is NAND-only: the SD-card persistent overlay from firmware #2411 is not used here.

For local testing, layer this directory over the local firmware tree and set a
Buildroot override file containing `LINUX_OVERRIDE_SRCDIR` and
`RTL8812AU_OPENIPC_OVERRIDE_SRCDIR` to the corresponding checked-out PR branches.
Pass its absolute path as `BR2_PACKAGE_OVERRIDE_FILE` when running
`make BOARD=rv1103_lite_luckfox-pico-mini-b`.

`general/overlay/etc/wfb.yaml` has no `telemetry:` section, so telemetry (`mavfwd`) is not
configured on this profile; `mavfwd` runs out of memory on this board. Video and
tunnel startup remain enabled. If UART3 telemetry is wanted later, add the section
(`router: mavfwd`, `serial: ttyS3`) and enable UART3 in the Mini B DTS.

Validate the booted model, USB host role, `88XXau` module loading, camera/video,
adapter unplug/replug, and persistence across reboot. Record results before
marking the device supported. No USB hub compatibility is claimed.
