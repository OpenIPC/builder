## Devices

### List of known and supported devices

```
XM       IVG-HP203Y-AE   HI3516CV300 IMX291                 NOR_16M   in progress
YUCHENG  F10H55W3AS      GK7205V300  IMX335  MT7601U_USB    NOR_16M   in progress
YUCHENG  F10H55W3AS-DEV  GK7205V300  IMX335  MT7601U_USB    NOR_16M   in progress
AKA      CH v1           GK7205V200  IMX307  RTL8733BU      NOR_16M   in progress
AKA      CH v2           GK7205V200  IMX307  MT7601U_USB    NOR_16M   in progress
AKA      CH-T31 v1       T31L        GC2083  MT7601U_USB    NOR_8M    in progress
AKA      CH-T31 v2       T31L        GC2083  RTL8188EU_USB  NOR_8M    in progress
XM       IVG-G3S         GK7205V210  IMX307  ATBM6032i_USB  NOR_16M   w/ext wifi board
```
### Upgrading 
- SD
```
# soc=$(fw_printenv -n soc)
# sysupgrade --kernel=/mnt/mmcblk0p1/uImage.${soc} --rootfs=/mnt/mmcblk0p1/rootfs.squashfs.${soc} -z --force_ver
...
# firstboot
```
- TFTP
```
# soc=$(fw_printenv -n soc)
# serverip=192.168.1.40
# cd /tmp
# tftp -r rootfs.squashfs.${soc} -g ${serverip}
# tftp -r uImage.${soc} -g ${serverip}
# sysupgrade --kernel=uImage.${soc} --rootfs=rootfs.squashfs.${soc} -z --force_ver
```


### Images
- [releases](https://github.com/akhud78/builder/releases)

#### XM IVG-HP203Y-AE
`./builder.sh hi3516cv300_ultimate_xm_ivg_hp203y_ae`

- hi3516cv300_ultimate_xm-ivg-hp203y-ae-nor.tgz

```
- uImage: [1727KB/2048KB]
- rootfs.squashfs: [6396KB/8192KB]
- archive/hi3516cv300_ultimate_xm_ivg_hp203y_ae/202405291849
```

#### YUCHENG F10H55W3AS-DEV
- Experimental: opencv3
- gk7205v300_ultimate_yucheng-f10h55w3as-dev-nor.tgz

`$ ./builder.sh gk7205v300_ultimate_yucheng-f10h55w3as-dev`

```
- uImage: [1855KB/2048KB]
- rootfs.squashfs: [7644KB/8192KB]
- archive/gk7205v300_ultimate_yucheng-f10h55w3as-dev/202406211446
```

#### YUCHENG F10H55W3AS
- Stable version
- gk7205v300_ultimate_yucheng-f10h55w3as-nor.tgz

`$ ./builder.sh gk7205v300_ultimate_yucheng-f10h55w3as`

```
- uImage: [1816KB/2048KB]
- rootfs.squashfs: [6260KB/8192KB]
- archive/gk7205v300_ultimate_yucheng-f10h55w3as/202406211652
```

#### AKA CH v1
```
- uImage: [1814KB/2048KB]
- rootfs.squashfs: [5080KB/5120KB]
- archive/gk7205v200_lite_aka-ch-v1/202405231116
```
#### AKA CH v2

`$ ./builder.sh gk7205v200_lite_aka-ch-v2`

- ngrep, mdns, mquery, gesftpserver, qrparse

```
- uImage: [1814KB/2048KB]
- rootfs.squashfs: [4788KB/5120KB]
- archive/gk7205v200_lite_aka-ch-v2/202406031459
```
#### AKA CH-T31 v1
```
- uImage: [1786KB/2048KB]
- rootfs.squashfs: [4384KB/5120KB]
- archive/t31_lite_aka-ch-v1/202405211035
```
#### AKA CH-T31 v2
```
- uImage: [1786KB/2048KB]
- rootfs.squashfs: [5064KB/5120KB]
- archive/t31_lite_aka-ch-v2/202405211318
```
#### XM IVG-G3S
- gk7205v210_lite_xm-ivg-g3s-nor.tgz
```
- uImage: [1814KB/2048KB]
- rootfs.squashfs: [4968KB/5120KB]
- archive/gk7205v210_lite_xm-ivg-g3s/202405281200
```


