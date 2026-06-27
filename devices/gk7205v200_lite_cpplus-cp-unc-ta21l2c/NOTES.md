![OpenIPC logo][logo]

## OpenIPC Builder
_Experimental system for building OpenIPC firmware for known devices_


### Release notes for the device

**CP Plus CP-UNC-TA21L2C** — Dahua-OEM 2 MP full-colour bullet/turret camera.

| | |
|---|---|
| SoC | Goke **gk7205v200** (lite), ARM Cortex-A7 |
| Sensor | SmartSens **SC223A** (chip-id `0xcb3e`), 2-lane MIPI, 1080p30 |
| Flash | 16 MiB SPI-NOR (XM25QH128); built with the standard 8 MiB layout |
| Wi-Fi | none (wired-only) |
| Audio | present on the hardware; not wired up in this profile yet |

#### Board specifics
The SC223A on this board is on the SoC's **hardware I2C0**, routed to the
**VI-RAW** pads (`0x112c0060/0x64`, func2) instead of the default mipi-sensor
pads (`0x112c0030/0x34`, func1) that the SDK `board=demo` bring-up probes. The
sensor also needs a 27 MHz MCLK (`0x120100f0 = 0x19`, div6); the SDK default
`0x11` (div4) leaves it unresponsive. Both are handled in
`general/overlay/etc/init.d/S71devmem`, which runs after `S70vendor`
(`load_goke`) and before `S95majestic`. No kernel module is required — the
stock `open_sensor_i2c` reaches the sensor over `/dev/i2c-0` once the pads are
muxed. Sensor reset/enable is `GPIO8_7` (`SENSOR_RSTN`, func2).

Verified on hardware: chip-id `0xcb3e` over HW I2C0, MIPI PHY lock at
1920x1080 with zero error counters, majestic streams correct colour 1080p.

#### TODO
- Characterise and wire up the IR-cut / night-mode GPIOs.
- Enable audio.


[logo]: https://openipc.org/assets/openipc-logo-black.svg
