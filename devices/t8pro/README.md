# Tripltek 8 Pro

> **Status: Most progress so far.** XDA reports indicate LineageOS 20 GSI boots with issues. Needs systematic test reporting.

---

## Known Specs

| Item | Value |
|------|-------|
| Stock Android | 10 |
| Display | 8" high-brightness LCD |
| SoC | MediaTek (model TBD) |
| RAM | TBD |
| Storage | TBD |
| Bootloader unlockable | Likely (T7 Pro is, T8 should follow) |
| Treble support | Likely (Android 10 era) — unconfirmed |
| TWRP | Not yet ported |
| LineageOS GSI tested | LOS 20 GSI boots, with unspecified issues |

---

## Known references

- [XDA: Root for Tripletek Pro Tablet](https://xdaforums.com/t/root-for-tripletek-pro-tablet.4353163/) — primary thread, reports of LOS 20 GSI on the T8 Pro

---

## What we need from owners

Same as T7 Pro plus:

1. **A clear test matrix** of which GSI variants you've tried and exactly what broke (camera, modem, sensors, audio, fingerprint, charging, etc.) — see [docs/gsi-test-template.md](../../docs/gsi-test-template.md)
2. **dmesg / logcat snippets** from the broken state
3. **Stock firmware backup** — needed by anyone trying to recover
4. **Working flash sequence** — exact commands that got you to a booting GSI

---

## Current blockers

- No public TWRP build
- No published, complete GSI test report (just scattered XDA replies)
- Kernel source not yet requested

---

## Roadmap

1. Consolidate XDA findings into a single test report
2. Confirm Treble status from a fresh device
3. Identify which subsystems break under GSI and why (vendor blob mismatch vs missing kernel feature)
4. Decide between continuing on GSI vs building a proper device tree
