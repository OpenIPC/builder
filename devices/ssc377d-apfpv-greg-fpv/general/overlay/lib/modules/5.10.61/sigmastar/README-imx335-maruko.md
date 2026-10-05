# SSC377D APFPV IMX335 sensor driver

This directory contains the Maruko/Infinity6C IMX335 kernel module used as a drop-in replacement for the stock OpenIPC Infinity6C IMX335 driver.

Source provenance: OpenIPC/waybeam `sensors/maruko/sensor_imx335_maruko.ko`, built from `drivers/sensor_imx335_maruko.c` for Infinity6C Linux 5.10.61.

The module is installed under the canonical OpenIPC name `sensor_imx335_mipi.ko` so the existing SigmaStar sensor loader can load it without changes to init scripts.

Upstream provenance:
- https://github.com/OpenIPC/waybeam/blob/master/drivers/sensor_imx335_maruko.c
- https://github.com/OpenIPC/waybeam/blob/master/sensors/maruko/README.md
- MD5: 470afdd5cecc8c80663b905b648563f2

This is intentionally a separate change from Wi-Fi/MSPOSD changes. No Majestic configuration or sensor IQ profile is changed here.
