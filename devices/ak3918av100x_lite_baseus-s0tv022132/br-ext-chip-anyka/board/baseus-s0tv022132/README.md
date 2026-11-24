# Baseus P1 Pro (S0TV022132)

AK3918AV100X, 8 MiB SPI NOR, SmartSens SC5336 and USB AIC8800D80. The split
NOR image assumes OpenIPC U-Boot is already installed.

The GPIO map, sensor, Wi-Fi, PTZ, indicator, IR-cut, illuminator and microSD
were tested with the local firmware profile on the camera. The reset button
polarity comes from the factory DTB. Audio is still under investigation.

## Build

From the Builder root on Linux:

```sh
OPENIPC_FW_REV=8a60044958d4b676eebe01c825cfd432547b5e4d \
bash builder.sh ak3918av100x_lite_baseus-s0tv022132
```

Use an isolated Builder checkout: `builder.sh` recreates its `openipc/`
working directory. The profile ships a board defconfig and uses upstream
`ak3918av100x.generic.config` for the kernel. The DTB patches live in this
profile. The profile uses the common Anyka AV100 SDK libraries and the
AIC8800 kernel modules from OpenIPC firmware.

Builder extends the AIC8800 package with an optional D80 firmware install hook.
This profile enables that option. The package installs the firmware from the
OpenIPC driver source tree under `/lib/firmware/aic8800D80`.

The SC5336 kernel module and its ISP tuning were extracted from the factory
Baseus firmware and are included here for local builds. The two files are
under `files/`; confirm redistribution terms before submitting them upstream.

The first-boot customizer sets the adapter, sensor and PTZ defaults in U-Boot
environment. Wi-Fi credentials are configured on the camera. The build assumes
the profile is applied to the pinned firmware tree above.

Factory payload SHA-256 digests:

- `sensor_sc5336.ko`: `296fa22a6ceaa7f0c2ba09cffa61cbea5863cdd1c47df2b22d204e7506d120ae`
- `isp_sc5336_mipi_2lane_av100_15fps_YuTong.conf`: `13b664071b0ae922b9e7efa70b58c1973f5c718a595681dfed7f5a89659ac8f6`
