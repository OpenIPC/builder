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
Azarton C1               T20X         JXF23     RTL8189FS_SDIO   NOR_16M   done
Azarton C1               T31X         GC2053    RTL8189FS_SDIO   NOR_16M   done
Babysense See HD IP206   SSC333       GC2053    RTL8188FU_USB    NOR_16M   done
Bathhouse                HI3518EV300  ?         RTL8188FU_USB    NOR_8M    research
ChinaTelecom DS-YTJ5301  SSC30KD      GC2053    RTL8188FU_USB    NOR_16M   video-ok, wifi-no, motors-no
ChinaTelecom Y4H-50      T31L         ?         ?                NOR_16M   new
CMCC HDC-51 A5-V12       T21N         SC2235    RTL8189FTV_SDIO  NOR_16M   in progress
CMCC HDC-51 A6-V11       T31L         SC2332    RTL8188FU_USB    NOR_16M   done
Cootli CAMV0103          GK7202V300   SC223A    SSV6355_USB      NOR_8M    in progress
Emax Wyvern Link         SSC338Q      IMX415                     NOR_16M   done
Foscam X5                SSC337DE     GC4653    RTL8188FU_USB    NOR_16M   done
G.Craftsman GCA50        T31ZX        GC4653    -                NOR_16M   done
EC37-T11                 T20L         SC2232    RTL8188FU_USB    MOR_16M   in progress
H3C TC2101               SSC337       JXQ03     RTL8188FU_USB    NOR_16M   done
HB-WIFI-Z6 v1.2          T10          JXH62     RTL8188EU_USB    NOR_8M    in progress
iFlytek XFP301-M         T31ZX        JXQ03     RTL8188FU_USB    NOR_?     research
Imilab EC3 CMSXJ25A      SSC325       GC2053    MT7603UN_?       NOR_16M   in progress
Imou IPC-C22E-S2-v2      SSC335DE     GC2053    RTL8188FU_USB    NOR_16M   done
Imou IPC-C22EP-S2        SSC325DE     SC2239    RTL8188FU_USB    NAND      testing stage 1
Imou IPC-C22EP-S2 ?      SSC325DE     SC2335    RTL8188FU_USB    NAND      wait driver
Imou IPC-F22AP           SSC325       SC2239    -                NOR_?     preparation
JVS INGT10 GQS60EP       T10A         OV9750    -                NOR_8M    done
Lenovo Snowman 1080P     HI3518EV200  SC2035    RTL8188EUS_USB   NOR_16M   in progress, LightSensor-no
Meari Speed 6S           SSC333       JXF37     RTL8188FU_USB    NOR_16M   video-yes, wifi-yes, motors-no
OpenIPC AIO Mario        SSC338Q      IMX335    RTL8812AU_USB    NOR_16M   done
OpenIPC AIO Thinker      SSC338Q      IMX335                     NOR_16M   in progress
OpenIPC AIO UltraSight   SSC338Q      IMX415    RTL8812AU_USB    NOR_16M   done
OpenIPC URLLC            SSC338Q                                 NOR_16M   done
Qtech QVC-IPC-136W       HI3518EV200  OV9732    RTL8188EU_USB    NOR_16M   done
RunCam WiFiLink          SSC338Q      IMX415                     NOR_16M   done
Smartwares CIP-37210     HI3518EV200  OV9732    RTL8188FU_USB    NOR_16M   in progress
Smartwares CIP-37210AT   T21N         JXF37     RTL8188FU_USB    NOR_16M   done
Switcam HS303 (v1)       HI3518EV200  JXF22     RTL8188FU_USB    NOR_16M   testing now
Switcam HS303 v2         HI3518EV200  OV9732    RTL8188EU_USB    NOR_16M   done
TP-Link Tapo C110 v1     SSC335       SC3335    ATBM6032i_USB    NOR_8M    done
TP-Link Tapo C110 v1     SSC337       SC3335    SSW101B_USB      NOR_8M    done
TP-Link Tapo C110 v2     SSC333       SC3338    SSW101B_USB      NOR_8M    done
TP-Link Tapo C110 v26    SSC333       ?         ?                NOR_?     done
TP-Link Tapo C310 v1     SSC325       SC3335    RTL8192EU_USB    NOR_8M    in progress
Trassir TR-D4121IR1 v2   HI3516CV200  AR0237    -                NOR_16M   done
Trassir TR-W2C1 v1       SSC325       GC2053    MT7601U_USB      NOR_16M   done
Trassir TR-W2C1 v2       SSC335       GC2053    MT7601U_USB      NOR_16M   done
Tuya GV7630-T31-PTZ      T31L         SC2336    ATBM6012B_USB    NOR_8M    in progress
Umea QC012               GK7102C_A    MIS2003   RDA5995_USB      MOR_8M    wip
Uniview C1L-2WN-G        SSC335DE     OS02G10   RTL8188FU_USB    NOR_16M   in progress
Vixand IPC-1             GK7205V200   none      EC200N_USB       NOR_8M    insert
Vixand IPH-5-4G          GK7205V200   SC2239    EC200N_USB       NOR_8M    insert
Vixand IVG-G3S           GK7205V210   IMX307    -                NOR_16M   !
Vixand IVG-G4F-A         GK7205V210   SC223A    -                NOR_16M   !
Vixand IVG-G4F-A-W       GK7205V210   SC223A    ATBM6032i_USB    NOR_16M   w/ext wifi board
Vixand IVG-G6S-W         GK7205V300   IMX335    ATBM6032i_USB    NOR_16M   w/ext wifi board
VStarcam C8892WIP        HI3518EV200  AR0237    MT7601U_USB      NOR_16M   done
VStarcam C8896WIP        GK7102C_A    GC2033    RTL8189ES_SDIO   NOR_8M    wip
VStarcam C43S(B)         SSC333       JXF37     MT7601U_USB      NOR_16M   in progress
VStarcam CS55            T31N         GC2053    RTL8188FU_USB    NOR_16M   in progress
Wansview Q5 1080p        T21Z         OV2735B   RTL8188FU_USB    NOR_16M   in progress
Wansview Q5 2K           T31L         SC2336    ATBM6031_SDIO    NOR_8M    done
Wyze V3 (WYZEC3B)        T31X         GC2053    RTL8189FS_SDIO   NOR_16M   done
X-06S v2.2               T21          JXH62     RTL8188FU_USB    NOR_8M    in progress
Xiaomi MJSXJ02HL         HI3518EV300  JXF22     RTL8189FS_SDIO   NOR_16M   preparation
Xiaomi MJSXJ03HL         T31N         JXQ03     RTL8189FS_SDIO   NOR_16M   done
Xiaomi MJSXJ03HL         T31N         JXQ03P    RTL8189FS_SDIO   NOR_16M   done
Xiaomi MJSXJ05HL         T31L         GC2053    ATBM6031_SDIO    NOR_16M   preparation
ZTE K540                 T31X         SC4336    ATBM6012B_USB    NOR_16M   done
4G Camera XG521 V1.2     GK7202V300   GC1054    EC800E-CN_USB    NOR_8M    done
```


### Compatibility and clones

Many devices sold in online stores are clones of original devices or, more often, devices adapted for the local national market.

```
Switcam HS303 v3                =>     Qtech QVC-IPC-136W
Rostelecom IPC8232SWC-WE-B      =>     Uniview C1L-2WN-G
```


### Device setup

#### WiFi Settings
Run these commands and enjoy:
```
fw_setenv wlanssid 'OpenIPC'
fw_setenv wlanpass 'mypassword'
reboot
```


### Requirements for registration of new devices

When adding new devices, please follow a few simple rules. 
The list of files to be added should be minimal, try not to store binary files, remember that all common files 
and configurations should be stored in the [firmware](https://github.com/openipc/firmware) repository. 
However, some list of files must be required.

```
processor_flavor_vendor-model-version/br-ext-chip-sigmastar/configs/processor_flavor_vendor-model-version_defconfig
processor_flavor_vendor-model-version/general/overlay/usr/share/openipc/customizer.sh
processor_flavor_vendor-model-version/general/scripts/excludes/processor_flavor.list
```

The file names contain variables with option names - **flavor, model, processor, vendor, version**

- flavor - firmware direction in the openipc system, by default try to use "lite" as much as possible
- model - official model name from the main device manufacturer
- processor - official name of the processor in the OpenIPC [structure](https://openipc.org/supported-hardware/full-list)
- vendor - the name of the official equipment manufacturer; if there are several of them, a [description](https://github.com/OpenIPC/builder/tree/master#compatibility-and-clones) is created
- version - usually this is an addition to the model, version or revision of hardware differences

### Preparing and using the project

```
sudo apt-get update -y
sudo apt-get install -y automake autotools-dev bc build-essential curl fzf git libtool rsync \
  unzip mc tree python-is-python3
git clone https://github.com/openipc/builder.git
cd builder
./builder.sh
```

### Create firmware with built-in credentials
- Usage: `repack.sh [uboot] [firmware] [ssid] [pass]`
```
sh repack.sh ssc337de ssc337de_ultimate_foscam-x5-nor router password
```

### Existing problems

- On some devices NOR flash 8M is small, and the WiFi driver is very large and the QR scanner currently does not fit into the firmware

### Additional information

- https://github.com/OpenIPC/wiki/blob/master/en/guide-supported-devices.md

### Technical support and donations

Please **_[support our project](https://openipc.org/support-open-source)_** with donations or orders for development or maintenance. Thank you!

[logo]: https://openipc.org/assets/openipc-logo-black.svg
