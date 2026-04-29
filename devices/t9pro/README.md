# Tripltek 9 Pro

> **Status: Untested.** SoC partially confirmed (MTK Helio G76), everything else unknown.

---

## Known Specs

| Item | Value |
|------|-------|
| Stock Android | 12 |
| Display | 9" high-brightness LCD |
| SoC | MediaTek Helio G76 (Cortex-A76 + Mali-G76 MC4) |
| RAM | TBD |
| Storage | TBD |
| Bootloader unlockable | Unknown (T7 Pro confirmed unlockable, likely the same path) |
| Treble support | Unknown — Android 12 era so probably yes |
| TWRP | Not yet ported |
| LineageOS GSI tested | Not yet |

---

## Why this device matters

The Helio G76 has appeared in multiple consumer tablets, so existing device trees and TWRP ports for unrelated G76 devices may be adaptable. This is the most likely Tripltek device to benefit from "borrowed" upstream work.

---

## What we need from owners

1. Full `adb shell getprop` dump
2. CPU-Z screenshot to confirm exact MediaTek model number (MT6769V/CU vs other G76 variants)
3. Treble Info screenshot
4. `/proc/partitions`, `/proc/cmdline`, `/sys/block/*/uevent`
5. Confirmation that Tripltek's unlock procedure works on this model too

---

## Current blockers

- Zero owner dumps in this repo yet
- No TWRP, no GSI test, no kernel source request
