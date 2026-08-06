# kc110-board-support

Buildroot package providing KC110-specific hardware support for OpenIPC. Delivers:

| File | Purpose |
|---|---|
| `/usr/bin/ptz` | C binary (mmap PL061) for pan/tilt + IR-cut + IR-LED via vendor-base-10 GPIO numbering |
| `/usr/bin/gpio-motors` | 451-byte shell shim that forwards calls to `ptz pan/tilt` (web-GUI compatible) |
| `/usr/bin/ir-control.sh` | Wrapper for IR-LED + IR-cut filter control |
| `/etc/init.d/S94pinmux-pan-ir` | Boot-time init that writes 0x1 to pinmux registers 0x200f00e8/ec/f0/fc/100/104 (KC110 chip7/8 pads) |

## Layout

```
kc110-board-support/
├── Config.in              # BR2_PACKAGE_KC110_BOARD_SUPPORT
├── kc110-board-support.mk # generic-package build + install rules
├── src/                   # source tree (compiled with target toolchain)
│   ├── Makefile
│   └── ptz.c              # ARM-static-stripped via cross-compile
└── files/                 # installed as-is (no build step)
    ├── etc/init.d/S94pinmux-pan-ir
    └── usr/bin/{gpio-motors,ir-control.sh}
```

## Use from upstream openipc-firmware

The package lives at the repo root (`kc110-board-support/`) but must be discoverable by Buildroot inside the upstream tree via a symlink:

```
openipc/openipc-firmware/general/package/kc110-board-support → ../../../../kc110-board-support
```

The symlink is reconstructed by the setup step (below).

## Setup after `git pull` of upstream

Because `openipc/` is gitignored, the wire-in edits in the upstream tree are lost on each pull. Re-apply them from `patches/openipc-wire-in-kc110.patch`:

```bash
cd openipc/openipc-firmware
git apply ../../patches/openipc-wire-in-kc110.patch

# Re-create the symlink if it disappeared:
[ -L general/package/kc110-board-support ] || \
  ln -s ../../../../kc110-board-support general/package/kc110-board-support
```

The patch adds:
- A `source` statement for the package in `general/package/Config.in`
- `BR2_PACKAGE_KC110_BOARD_SUPPORT=y` to `hi3518ev200_ultimate_defconfig` and removes `BR2_PACKAGE_GPIO_MOTORS=y` (our shim replaces upstream's gpio-motors binary)

## Build

Picked up automatically by `BOARD=hi3518ev200_ultimate make all` once the wire-in is applied. The `ptz` binary builds reproducibly — md5 `e70f78d73c91248ba044082e3f21c54b` across rebuilds.

## Conflict with upstream gpio-motors

`BR2_PACKAGE_GPIO_MOTORS` (upstream) and `BR2_PACKAGE_KC110_BOARD_SUPPORT` both install `/usr/bin/gpio-motors` and cannot be enabled simultaneously. The wire-in patch removes `BR2_PACKAGE_GPIO_MOTORS=y` from the defconfig to avoid the collision.
