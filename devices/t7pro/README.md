# Tripltek 7 Pro (T7121)

> **Status: LineageOS 19.1 (Android 12L) runs as a daily driver** on a GSI, with one library patch.
> Bootloader unlock is confirmed via standard `fastboot flashing unlock`. Tested 2026-10-16/17 on one unit.

---

## Specs (from a real unit)

| Item | Value |
|------|-------|
| Model / device | `T7121` / `T7121` (fastboot product `soten6771_p_t71v4`) |
| Last stock build | `T7121-20210420-EN-GMS`, Android 9 (SDK 28), patch 2021-05-01, vendor patch 2019-04-05 |
| SoC | **MediaTek MT6771** (Helio P60/P70), arm64, hw code `0x788` |
| RAM / storage | 8 GB / 128 GB eMMC |
| Display | 720×1280, ILI9881C controller (Holitech panel), density 216 |
| Kernel | 4.4.146 (built 2021-04-20) |
| Treble | yes, VNDK 28, arm64, system-as-root |
| Partitions | A-only, **no** dynamic partitions (`super`), **no** `vbmeta` |
| Encryption | FDE (`forcefdeorfbe=` in the vendor fstab) |
| Chip security | **SBC, SLA and DAA all disabled**: BROM mode (mtkclient) works without auth, so the tablet can always be recovered |
| Modem | yes, LTE (`MOLY.LR12A.R3.MP.V54.5`) |
| ODM / BSP | Soten `soten6771_p_t71v4` on MediaTek reference `k71v1_64_bsp`, `alps-mp-p0.mp1-V5.75` |

The stock system is signed with **test-keys**, meaning AOSP's public keys rather than Tripltek's.

**Irreplaceable partitions:** `nvram`, `nvdata`, `nvcfg`, `protect1/2` and `proinfo` hold the unit's IMEI,
Wi-Fi/BT calibration and MAC addresses. Back them up before changing anything.

---

## Install LineageOS 19.1 (what worked)

You need a Linux PC with `adb`/`fastboot`, [mtkclient](https://github.com/bkerler/mtkclient) in
`third_party/mtkclient` (see the main README), and `e2fsprogs`/`7z`. **Unlocking erases the tablet.**

1. **Full backup over BROM** (read-only, works with the bootloader locked):
   `tools/backup.sh T7121`. Power the tablet off, then hold both volume keys while plugging in USB.
   `tools/verify-backup.sh` checks every image against the GPT. Keep two copies.
2. **Unlock:** Settings → About → tap Build number 7× → Developer options → **OEM unlocking** on.
   Then `adb reboot bootloader` and `fastboot flashing unlock`, and press **Volume Up** on the tablet to confirm.
   The tablet wipes itself and shows an orange "unlocked" warning on every boot from then on.
3. **Get the GSI:** AndyYan's `lineage-19.1-20250606-UNOFFICIAL-arm64_bvS.img.gz` (or `bvN` for no root)
   from [SourceForge](https://sourceforge.net/projects/andyyan-gsi/files/lineage-19.x/). Check its MD5, then `gunzip`.
4. **Patch the GPS library** (without this, system_server hangs forever, see below). Extract your stock
   system image (`7z x -oextracted/T7121/system backups/…/partitions/system.bin`), then:
   ```
   tools/patch-vndk.sh lineage-19.1-…-arm64_bvS.img lineage-19.1-gnss.img extracted/T7121/system 28 android.hardware.gnss@1.0.so
   ```
5. **Charge the battery** (the bootloader aborts flashing below about 3.6 V; the script requires 3.8 V), then:
   ```
   adb reboot bootloader
   tools/flash-gsi.sh lineage-19.1-gnss.img      # flashes system, erases userdata + cache, reboots
   ```
   The first boot formats and encrypts `/data` and reaches the setup wizard in about a minute.
6. Disable the stock Xiaomi location helper, which crashes on Android 12:
   `adb shell pm disable-user --user 0 com.xiaomi.metoknlp`

To update later, flash a newer patched image with `tools/flash-gsi.sh <img> --keep-data`. A build signed
with different keys needs a data wipe.

---

## What works on LineageOS 19.1

| Feature | Status |
|---------|--------|
| Boot, setup wizard, encryption (FDE) | ✅ |
| Wi-Fi (2.4 + 5 GHz) | ✅ |
| Bluetooth | ✅ on |
| Sensors (accel, gyro, compass, light, proximity, pressure, …) | ✅ all 11 detected |
| Cameras | detected (back + front); capture not yet reported |
| Speaker | output device present; not yet reported by ear |
| GPS | ✅ GNSS HAL runs after the patch; outdoor fix not yet tested |
| Charging | ✅ |
| LTE modem | modem up; untested without a SIM |
| Battery percentage | ⚠️ unreliable (sat at 87–88% while voltage moved 3.5–3.7 V) |
| Root | `bvS` build: `su` works from adb |
| F-Droid / Aurora Store | ✅ |
| Not working | `android.hardware.moduleserver@1.0-service` (Soten HAL; its lib isn't in the GSI's VNDK list). No visible effect so far |

---

## Why other GSIs fail (and how this was debugged)

| GSI | Result | Root cause |
|-----|--------|-----------|
| LineageOS 20 (A13) `arm64_bvS` 2025-10-21 | Boot animation forever, no USB | `/data` never mounts. Android 13 removed FDE, so init treats the "needs encryption" result as `fs_mgr_mount_all() returned unexpected error`. It also left the ext4 **`project`** feature on userdata |
| LineageOS 19.1 on that userdata | Boot animation forever | Kernel 4.4 can't mount ext4 `project` (`unsupported optional features (2000)`). Fix: erase userdata so Android 12 reformats it |
| LineageOS 19.1, stock VNDK | system_server watchdog loop | The MediaTek GNSS HAL needs MediaTek's modified `android.hardware.gnss@1.0.so` (`BpHwGnss::_hidl_write`). The GSI's AOSP copy lacks it, so the HAL never starts and `GnssNative.initializeHal` blocks forever. Fix: `tools/patch-vndk.sh` |

A hung GSI boot never starts adb. To see inside it, `tools/add-bootlog.sh` builds a debug copy of the image
that snapshots dmesg, logcat, props and mounts into `/cache/bootlog` every 5 s. Read the cache partition
back over BROM (`mtk.py r cache cache.bin`) and unpack it with `tools/read-bootlog.sh`.

**Android 13+ on this tablet** would need the vendor fstab changed to drop FDE, plus a way to keep ext4
`project` off userdata. Android 14 also expects eBPF features that kernel 4.4 lacks, so networking may break.
Untested. It is the only route to newer security patches, since LineageOS 19.1 GSIs stopped in June 2025.

### Tool and bootloader quirks

- `fastboot -w` fails with distro fastboot builds whose `mke2fs` lacks android_sparse. Use
  `fastboot erase userdata`; the fstab marks it `formattable`. `tools/flash-gsi.sh` does this.
- lk reports `partition-size:system` as bare hex (`c0000000`), and `battery-voltage` is read once at boot.
  At 3.60 V it aborted a system flash about 90% of the way through; at 3.87 V and above it flashes fine.
- mtkclient v2.1.4.1: `r a,b,c fa,fb,fc` reuses the first partition's length for every partition after it.
  Use one partition per `r` (e.g. `multi "r a fa;r b fb"`) or `rl`.

---

## Display brightness and thermal

This repo used to warn that Tripltek firmware has display thermal limits a custom ROM would lose.
On the T7 Pro there are none.

| Layer | What's there |
|-------|--------------|
| Backlight hardware | MT6370 PMIC backlight driver (4 channels, PWM from DISP_PWM) with **hardware** over-current/over-voltage protection |
| Kernel | Standard MediaTek display/AAL path. Backlight coolers `mtk-cl-backlight01..03` exist but are **bound to no thermal zone** |
| Thermal policy | `/vendor/etc/.tp/*`, obfuscated with a per-character shift; `tools/re/mtc_decode.py` decodes it. Stock MediaTek: CPU, camera, modem and charging coolers, **no backlight** |
| Auto-brightness | MediaTek reference curve: lux 128…18432 → backlight 8…255 |
| ODM driver | `soten_gpio`: plain on/off power GPIOs (`lcm_led_pwr`, UHF, scanner, RS232…), no temperature logic |
| Apps | no Tripltek brightness or thermal app |

**Live test** (rooted, LineageOS 19.1 on the stock kernel and vendor, `tools/thermal-watch.sh 600 15`): 10 minutes at
brightness 255 with 8 busy CPU threads, AP up to 47 °C, CPU 78 °C. The backlight cooler stayed at 0 and the
kernel backlight stayed at 255, apart from a normal screen-dim timeout. **No thermal backlight limiting.**
Not yet tested in direct sun. A GSI keeps the stock kernel and vendor, so all of this carries over unchanged.
A custom kernel should keep the PMIC backlight settings.

---

## Porting notes

- The T8 Pro is reported as Helio P60 (MT6771) too, so this recipe may carry over. Reports welcome.
- Reference kernel source for a real device tree: MT6771 devices with published 4.4 source,
  e.g. Realme 3 (RMX1821).
- Partition map: `boot` p28, `recovery` p2, `system` p34, `vendor` p33, `userdata` p36, `cache` p35,
  `dtbo` p30, `lk`/`lk2` p26/27, `seccfg` p11, `nvram` p25, `nvdata` p7, `nvcfg` p6, `protect1/2` p9/10,
  `proinfo` p13, `md1img` p14.
