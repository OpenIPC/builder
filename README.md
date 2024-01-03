![OpenIPC logo][logo]

## OpenIPC Builder
**_Experimental system for building OpenIPC firmware for known devices_**
- **_[Current release of firmware builds](https://github.com/OpenIPC/builder/releases/tag/latest)_**


### Specialized features

- Tweaker for automatically configuring devices according to profile (gpio, wifi, etc).
- Specialized _[storage location](https://github.com/OpenIPC/builder/releases/tag/latest)_ for customized firmware for well-known devices.
- QR code recognition to automatically _[connect to WiFi](https://openipc.org/tools/qr-code-generator)_ on your home network.


### List of known and supported devices

```
Aoni EP01J05             T31L         ?         RTL8188FU_USB    NOR_16M   new
ChinaTelecom DS-YTJ5301  SSC30KD      GC2053    RTL8188FU_USB    NOR_16M   video-ok, wifi-no, motors-no
ChinaTelecom Y4H-50      T31L         ?         ?                NOR_16M   new
Imilab EC3 CMSXJ25A      SSC325       GC2053    MT7603UN_?       NOR_16M   in progress
Imou IPC-C22EP-S2        SSC325DE     SC2239    RTL8188FU_USB    NAND      testing stage 1
Imou IPC-C22EP-S2 ?      SSC325DE     SC2335    RTL8188FU_USB    NAND      wait driver
Imou IPC-F22AP           SSC325       SC2239    -                NOR_?     preparation
Qtech QVC-IPC-136W       HI3518EV200  OV9732    RTL8188EU_USB    NOR_16M   in progress
Smartwares CIP-37210     HI3518EV200  OV9732    RTL8188FU_USB    NOR_16M   in progress
Meari Speed 6S           SSC333       JXF37     RTL8188FU_USB    NOR_16M   video-yes, wifi-yes, motors-no
OpenIPC GK307 v1         GK7205V300   IMX307    -                NOR_16M   preparation
Switcam HS303            HI3518EV200  JXF22     RTL8188FU_USB    NOR_16M   in progress
Switcam HS303 v2         HI3518EV200  OV9732    RTL8188EU_USB    NOR_16M   in progress
TP-Link Tapo C110 v1     SSC335       SC3335    ATBM6032i_USB    NOR_8M    in progress
TP-Link Tapo C110 v2     SSC333       SC3338    SSW101B_USB      NOR_8M    in progress
Trassir TR-D4121IR1 v2   HI3518EV200  AR0237    -                NOR_8M    in progress
Trassir TR-W2C1 v2       SSC335       GC2053    MT7601U_USB      NOR_16M   in progress
Uniview C1L-2WN-G        SSC335DE     OS02G10   RTL8188FU_USB    NOR_16M   testing stage 2
VStarcam C8892WIP        HI3518EV200  AR0237    MT7601U_USB      NOR_16M   in progress
Wansview Q5 1080p        T21Z         OV2735B   RTL8188FU_USB    NOR_16M   in progress
Wansview Q5 2K           T31L         SC2336    ATBM6032i_SDIO   NOR_8M    preparation
Xiaomi MJSXJ02HL         HI3518EV300  JXF22     RTL8189FS_SDIO   NOR_16M   preparation
Xiaomi MJSXJ03HL         T31N         JXQ03P    RTL8189FS_SDIO   NOR_16M   in progress
Xiaomi MJSXJ05HL         T31L         GC2053    ATBM6031_SDIO    NOR_16M   preparation
```


### Compatibility and clones

Many devices sold in online stores are clones of original devices or, more often, devices adapted for the local national market.

```
Switcam HS303 v3                =>     Qtech QVC-IPC-136W
Rostelecom IPC8232SWC-WE-B      =>     Uniview C1L-2WN-G
```


### Preparing and using the project

```
sudo apt-get update -y
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync \
  unzip mc tree python-is-python3
git clone https://github.com/openipc/builder.git
cd builder
./builder.sh
```

### Existing problems

- On some devices NOR flash 8M is small, and the WiFi driver is very large and the QR scanner currently does not fit into the firmware


### Technical support and donations

Please **_[support our project](https://openipc.org/support-open-source)_** with donations or orders for development or maintenance. Thank you!


[logo]: https://openipc.org/assets/openipc-logo-black.svg

