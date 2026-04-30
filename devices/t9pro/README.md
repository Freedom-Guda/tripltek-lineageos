# Tripltek 9 Pro

> **Status: Untested, but unlockable.** SoC partially confirmed (MTK Helio G76), OEM unlocking confirmed available in Developer options.

---

## Known Specs

| Item | Value |
|------|-------|
| Stock Android | 12 |
| Display | 9" high-brightness LCD |
| SoC | MediaTek Helio G76 (Cortex-A76 + Mali-G76 MC4) |
| RAM | TBD |
| Storage | TBD |
| Bootloader unlockable | Yes — OEM unlocking confirmed available |
| Treble support | Unknown — Android 12 era so probably yes |
| TWRP | Not yet ported |
| LineageOS GSI tested | Not yet |

---

## Why this device matters

The Helio G76 has appeared in multiple consumer tablets, so existing device trees and TWRP ports for unrelated G76 devices may be adaptable. This is the most likely Tripltek device to benefit from "borrowed" upstream work.

---

## Bootloader unlock

The T9 Pro exposes the standard **OEM unlocking** toggle in Developer options, which means Tripltek did not strip the AOSP unlock path on this model. This is the cleanest unlock signal of any Tripltek device so far — better than the T7 Pro's "support says yes, procedure unclear" status.

Standard sequence (do not run these blindly — they will wipe userdata):

```
# On device: Settings → System → Developer options → enable "OEM unlocking"
adb reboot bootloader
fastboot flashing unlock
# follow on-screen prompt to confirm
```

If you've actually run this on a T9 Pro, please open a [bootloader unlock report](../../.github/ISSUE_TEMPLATE/bootloader-unlock-report.md) so we can confirm the post-unlock state (warning banner, fastboot still accessible, relock behavior, etc.).

---

## What we need from owners

1. Full `adb shell getprop` dump
2. CPU-Z screenshot to confirm exact MediaTek model number (MT6769V/CU vs other G76 variants)
3. Treble Info screenshot
4. `/proc/partitions`, `/proc/cmdline`, `/sys/block/*/uevent`
5. Bootloader unlock walkthrough — exact state after `fastboot flashing unlock`

---

## Current blockers

- Zero owner dumps in this repo yet
- No TWRP, no GSI test, no kernel source request
