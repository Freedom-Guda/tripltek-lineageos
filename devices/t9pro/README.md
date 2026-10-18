# Tripltek 9 Pro (T93)

> **Status: Untested, but a strong candidate.** SoC confirmed from a real `getprop` dump
> ([issue #1](https://github.com/Freedom-Guda/tripltek-lineageos/issues/1)): **MT6785**, not "Helio G76" as
> first listed. OEM unlocking is available in Developer options.

---

## Specs (from issue #1)

| Item | Value |
|------|-------|
| Model / product | `TRIPLTEK T93` / `TRIPLTEK_T93`, build `TRIPLTEK_T93_20250122` |
| SoC | **MT6785V/CD** (Helio G90T/G95 family), `ro.hardware=mt8789` |
| CPU | 2× Cortex-A76 + 6× Cortex-A55, arm64 |
| Stock Android | 12 (SDK 31), patch 2023-04-05, vendor patch 2022-11-01 |
| Kernel | 4.14.186 (clang 11.0.1, built 2025-01-22) |
| Treble | yes, VNDK 31, board first API 30 |
| Partitions | A/B + virtual A/B, dynamic (`super`), UFS (`/dev/block/sdc*`) |
| Verified boot | green, locked; OEM unlocking toggle present |
| BSP / modem | `alps-mp-s0.mp1-V14.99.2` / `MOLY.LR13.R1.MP.V184` |
| Density | 320 |

`ro.build.fingerprint` is spoofed (`T_mini`, Android 13); the real one is in `persist.sys.modifyfingerprint`.
Don't trust the fingerprint when matching firmware.

---

## Why it looks easier than the T7 Pro

The three things that blocked newer GSIs on the [T7 Pro](../t7pro/) shouldn't apply here:

- **Encryption:** an Android 12 launch device uses FBE, not the FDE that Android 13+ dropped.
- **Kernel 4.14:** supports ext4 `project` quotas and the eBPF features newer Android expects (4.4 doesn't).
- **VNDK 31:** a much closer match for current GSIs. MediaTek-modified VNDK libraries (the T7's GPS problem)
  can still bite, and `tools/patch-vndk.sh` handles that.

So a current, still-updated GSI (e.g. LineageOS 21) is a realistic target. MT6785 also powers the Redmi
Note 8 Pro (`begonia`), which has public 4.14 kernel source and community LineageOS trees for reference.

---

## Before unlocking: rescue your data

Unlocking wipes userdata. On Android 12, `adb backup` skips app data for apps targeting API 31+, so don't
rely on it for games or app settings. Use in-app cloud saves or accounts, copy media and flight logs
(DJI apps keep them in internal storage, and records sync to a DJI account), and take a full BROM backup with
`tools/backup.sh` if mtkclient can talk to this SoC (not yet confirmed; newer MediaTek preloaders may need auth).

---

## Bootloader unlock

The T9 Pro exposes the standard **OEM unlocking** toggle, so Tripltek didn't strip the AOSP unlock path.
The same sequence worked on the T7 Pro:

```
# On device: Settings → System → Developer options → enable "OEM unlocking"
adb reboot bootloader
fastboot flashing unlock
# confirm on the tablet (Volume Up on the T7 Pro)
```

GSIs on A/B + dynamic partitions are flashed from **fastbootd** (`fastboot reboot fastboot`), with vbmeta
verification disabled. `tools/flash-gsi.sh` currently targets the T7's layout (A-only, no `super`), so it
needs extending for this device.

If you've run this on a T9 Pro, please open a
[bootloader unlock report](../../.github/ISSUE_TEMPLATE/bootloader-unlock-report.md).

---

## What we need from owners

1. `tools/recon.sh` output (read-only; it redacts nothing, so remove the serial and MACs before posting)
2. Whether `tools/backup.sh` (mtkclient BROM) connects, and its "SBC/SLA/DAA enabled" lines
3. Bootloader unlock walkthrough: the exact state after `fastboot flashing unlock`
4. GSI reports using [docs/gsi-test-template.md](../../docs/gsi-test-template.md)
