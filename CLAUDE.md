# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

OpenIPC **builder** is a thin Buildroot *overlay* layer for building OpenIPC IP-camera
firmware for specific, named consumer devices. It contains **only the per-device deltas**
(a defconfig, a first-boot customizer, a rootfs exclude list, occasional sensor/board
files). Everything common — the actual Buildroot tree, packages, kernels, toolchains — lives
in [`OpenIPC/firmware`](https://github.com/openipc/firmware), which `builder.sh` clones fresh
on every run. This repo is never built in isolation; it is layered on top of a firmware
checkout.

## Build commands

```sh
./builder.sh                       # interactive whiptail menu of all devices
./builder.sh <device>              # build one device non-interactively
```

`<device>` is the directory name under `devices/` (minus the `_defconfig` suffix on its
config), e.g. `hi3518ev200_lite_switcam-hs303`. It is passed straight through as
`make BOARD=<device>`. There is no separate test/lint suite — "passing" means the firmware
image builds and (ideally) boots on hardware.

What `builder.sh <device>` does, in order:
1. `git pull` (self-update the builder repo).
2. `rm -rf openipc` then clone `OpenIPC/firmware` — HEAD by default, or the ref in
   `$OPENIPC_FW_REV` if set (used for cross-repo bisects; see build-one.yml).
3. `copy_extra_packages` — copy `package/*` into `openipc/general/package/` and append a
   `source "...Config.in"` line for each into the external tree's `Config.in`.
4. Copy `devices/<device>/*` over the firmware tree (defconfig, overlay, excludes, board).
5. `make BOARD=<device>` then best-effort `make BOARD=<device> size-report`.
6. `copy_to_archive` → `archive/<device>/<timestamp>/`. For `hi3518ev200_lite` it also runs
   `autoup_rootfs` to wrap the images as `autoupdate-*.img` via `mkimage`.

`openipc/`, `archive/`, `cache/`, `output/` are all gitignored build artifacts.

### Other scripts
- `repack.sh [uboot] [firmware] [ssid] [pass]` — does **not** build. Downloads a prebuilt
  release `.tgz` + u-boot from GitHub releases, optionally bakes in WiFi creds via
  `fw_setenv`, and `dd`s a flashable NOR image. Needs `squashfs-tools`.
- `package.sh [pkg]` — force a full rebuild of one Buildroot package inside an existing
  `openipc/` tree (`dirclean` + `rebuild`; defaults to `busybox`).

## Device anatomy

Device directory names encode `<soc>_<flavor>_<vendor>-<model>[-<version>]`:
- **soc** — OpenIPC SoC name: `hi3518ev200`, `ssc337de`, `t31`, `gk7205v200`, …
- **flavor** — firmware track: `lite` (default, the vast majority), `ultimate`, `fpv`,
  `rubyfpv`, `apfpv`. Prefer `lite` for new devices unless flash size forces otherwise.

The minimal required files for a registered device (per README "Requirements"):
```
devices/<device>/br-ext-chip-<vendor>/configs/<device>_defconfig
devices/<device>/general/overlay/usr/share/openipc/customizer.sh
devices/<device>/general/scripts/excludes/<soc>_<flavor>.list
```
- **`br-ext-chip-<vendor>/`** — the chip-vendor folder mirrors firmware's `BR2_EXTERNAL`
  layout. One of: `br-ext-chip-hisilicon`, `br-ext-chip-sigmastar`, `br-ext-chip-goke`,
  `br-ext-chip-ingenic` (Ingenic = the T-series SoCs). The defconfig inside selects
  toolchain/kernel/SoC drivers and majestic/webui packages; it references `$(OPENIPC_*)`
  and `$(EXTERNAL_VENDOR)` macros resolved by the firmware Makefile, not by this repo.
- **`customizer.sh`** — runs on first boot. Applies device-specific runtime config:
  `fw_setenv` (upgrade URL, `wlandev`, `ptz` profile, WiFi) and `cli -s .<path> <value>`
  to seed majestic's config (sensor ini, IR-cut/backlight GPIO pins, codec, fps).
- **`<soc>_<flavor>.list`** — paths to **delete** from the rootfs (unused sensor `.so`/`.ini`,
  unused WiFi `.ko`, etc.) so the image fits NOR flash. This is the main lever for the
  "doesn't fit in 8M NOR" problem.

Optional per-device files: extra `general/overlay/...` payload (a sensor `libsns_*.so`, a
sensor `.ini`, a patched `load_hisilicon`), or a custom kernel config at
`br-ext-chip-<vendor>/board/<family>/<soc>.generic.config`.

### `devices/common/`
Generic, non-device-specific defconfigs (`*_fpv`, `*_venc`, `*_lte`, `*_mini`) plus their
shared kernel configs and exclude lists. These are the matrix entries with a single
underscore (`hi3516ev200_fpv`, `hi3518ev200_mini`). The CI artifact-naming logic keys off
this: `COMMON = (underscore count) - 1`; when `COMMON == 1` the firmware's canonically-named
image is uploaded as-is, otherwise the compound `<soc>_<flavor>_<vendor>-<model>` image is
renamed to `<device>-nor.tgz` / `-nand.tgz` to avoid release-asset collisions.

## Adding a new device

The fastest correct path is to clone the closest existing device — **same SoC and same
flavor** — and edit the deltas. Identify the target's SoC, image sensor, WiFi chip, and flash
size first (the README device table lists all of these for existing boards).

1. **Copy a sibling.** `cp -r devices/<soc>_<flavor>_<other> devices/<soc>_<flavor>_<vendor>-<model>`.
   The new directory name *is* the `BOARD`/`<device>` token; keep it
   `<soc>_<flavor>_<vendor>-<model>[-<version>]`, lowercase, hyphen-separated vendor/model.
2. **Rename + edit the defconfig.** It lives at
   `br-ext-chip-<vendor>/configs/<device>_defconfig` and its filename must match the new
   directory name exactly (this is what `make BOARD=` looks up). Inside, the lines you
   typically change:
   - WiFi driver — the `BR2_PACKAGE_<chip>_OPENIPC=y` line (e.g. `RTL8188FU`, `RTL8189FS`,
     `ATBM…`). Pick the one matching the device's WiFi module.
   - `BR2_OPENIPC_FLASH_SIZE="8"` / `"16"` to match the NOR/NAND size.
   - Leave `BR2_OPENIPC_SOC_*`, `BR2_OPENIPC_VARIANT`, the toolchain/kernel block, and the
     `*_OSDRV_*` sensor-driver package alone unless the SoC/flavor actually differs.
3. **Edit `general/overlay/usr/share/openipc/customizer.sh`** (runs on first boot):
   - `fw_setenv upgrade '…/releases/download/latest/<device>-nor.tgz'` — the filename **must**
     equal `<device>-nor.tgz`, because that is exactly what CI renames the artifact to (see
     the `COMMON` logic above). Getting this wrong breaks self-update.
   - `fw_setenv wlandev <driver-profile>`; optional `fw_setenv ptz <profile>`.
   - `cli -s .<path> <value>` to seed majestic — IR-cut / backlight / light-sensor GPIO pins,
     codec, fps. Only set `.isp.sensorConfig /etc/sensors/<sensor>.ini` when the sensor needs
     a non-default config (most boards don't — it's the exception, e.g. MIPI sensors).
4. **Trim the exclude list.** Keep the filename `<soc>_<flavor>.list` (it is named after
   soc+flavor, **not** the full device name — do not rename it to the device). Remove from the
   list the sensor `.so`/`.ini` and WiFi `.ko` that *this* board actually uses, so they survive
   into the rootfs; everything else listed gets stripped to fit flash. Sibling devices on the
   same `<soc>_<flavor>` often share an identical list — diff against them.
5. **Optional payload.** Add files under `general/overlay/…` only when required (a
   `libsns_<sensor>.so` not provided by the SoC osdrv, a patched `load_hisilicon`, a sensor
   `.ini`), or a custom kernel config at `br-ext-chip-<vendor>/board/<family>/<soc>.generic.config`.
   Keep the file count minimal — anything reusable belongs upstream in `OpenIPC/firmware`.
6. **Register for nightly CI.** Add `- <device>` to the matrix in
   `.github/workflows/master.yml` under the matching group (SoC/APFPV/FPV/Ruby/etc.). This
   matrix is the *only* build registry — a device not listed here is never built or released.
7. **Document it.** Add a row to the device table in `README.md` (and the clones table if it's
   a rebrand of an existing board).
8. **Build & verify locally.** `./builder.sh <device>`, then check
   `archive/<device>/<timestamp>/` for the image and confirm it fits the flash size. Use
   `package.sh <pkg>` to iterate on a single package without a full re-clone.

## `package/` — builder-local Buildroot packages

Standard Buildroot packages (`Config.in` + `<name>.mk` + `src/` and/or `files/`) that aren't
(yet) upstream in firmware. `copy_extra_packages` in `builder.sh` injects them at build time.
Examples: `kc110-board-support` (a device-specific C PTZ/IR binary + init scripts, installed
via `SITE_METHOD = local`), `demo-openipc`. Read the package `Config.in` help text — e.g.
`kc110-board-support` documents the device's exact GPIO/pinmux map.

## CI (`.github/workflows/`)

- **master.yml** ("Build") — nightly cron (03:00 UTC) + manual dispatch. Builds the full
  device matrix; it always rebuilds (the input that actually changes is firmware HEAD /
  toolchain / kernel, all *outside* this repo, so there is no skip-gate). Caches ccache and
  Buildroot's `BR2_DL_DIR` at `/tmp/builder-dl` (outside `openipc/` because `builder.sh`
  `rm -rf`s that tree each run). Uploads each image to three release tags: dated
  `nightly-YYYYMMDD-<sha>`, rolling `nightly`, and legacy `latest`; pushes the NOR build to
  Telegram.
- **build-one.yml** — dispatch one platform at a chosen builder `commit` and/or firmware
  `firmware_ref`. Built for `git bisect run` across either repo; publishes to
  `nightly-bisect-*`.
- **manifest.yml** — after Build finishes (success *or* partial failure), regenerates
  `manifest.json` + `manifest.flat` on the `gh-pages` branch via
  `.github/scripts/enrich_manifest.py`.
- **cleanup.yml** — weekly prune of dated `nightly-*` releases beyond the newest 90.

### Moving-ref cache caveat
The monthly `builder-dl` cache can freeze packages pinned to a moving ref (VERSION = HEAD /
branch, or the `majestic-webui` `dist` asset) because they download under a constant
`<pkg>-<ref>.tar.gz` filename. Both build workflows have a "Refresh moving-ref package
downloads" step that deletes `*-HEAD/master/main/dist.tar.gz` from the cache so Buildroot
re-fetches them each run. If you add a package pinned to a branch, make sure its tarball name
matches that glob or it will go stale silently.

## Project memory (kaeru)

Device-specific build/runtime gotchas, recovery procedures, and hardware quirks are recorded
in the **kaeru** `builder` initiative — query it before debugging a board (e.g. the
"overlay wipe removes ssh authorized_keys", "busybox `ip` has no `br` flag", and
generic→builder migration notes already there). Put new technical findings in kaeru, not here.
