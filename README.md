# Tripltek LineageOS Project

> **Community effort to bring LineageOS (and other custom ROMs) to all Tripltek devices.**

Tripltek makes some of the brightest, most rugged Android tablets on the market — favored by drone pilots, field workers, and outdoor professionals. But their devices ship with outdated Android versions, no security updates, and no path to a modern OS. This project aims to fix that.

---

## Goals

- **Primary:** Get LineageOS running on every Tripltek device
- **Immediate focus:** Tripltek 7 Pro (oldest, most in the wild, best candidate)
- **Then:** T8 Pro → T9 Pro → Mini → X Pro
- **Stretch goal:** Full device trees, kernel source, and official LineageOS submissions

The more devices we cover, the more developers this project attracts. Help with any device is welcome.

---

## Device Status

| Device | Android Stock | SoC (confirmed) | Bootloader Unlockable | Treble | TWRP | LineageOS GSI | Notes |
|--------|--------------|-----------------|----------------------|--------|------|---------------|-------|
| [T7 Pro](devices/t7pro/) | Android 9 | MTK (model TBD) | Yes (Tripltek confirmed) | Unknown | None | Untested | **Active focus** |
| [T8 Pro](devices/t8pro/) | Android 10 | MTK (model TBD) | Likely | Unknown | None | LOS 20 GSI boots w/ issues | XDA reports partial success |
| [T9 Pro](devices/t9pro/) | Android 12 | MTK Helio G76 (A76/Mali-G76 MC4) | Yes (OEM unlocking exposed) | Unknown | None | Untested | |
| [Mini](devices/mini/) | Android 12 | MTK (model TBD) | Unknown | Unknown | None | Untested | Phone form factor |
| [X Pro](devices/xpro/) | Android (TBD) | MTK AI chip (model TBD) | Unknown | Unknown | None | Untested | Newest, Micro-LED |

---

## How to Contribute

You don't need to be a developer to help. Every Tripltek owner can contribute:

### If you own any Tripltek device:
1. **Run `adb shell getprop`** and submit the output → [info dump template](docs/how-to-dump-device-info.md)
2. **Install CPU-Z or AIDA64** and screenshot the SoC page → confirms the MediaTek model number
3. **Install "Treble Info"** from Play Store → tells us if GSI flashing is possible
4. **Report what works/breaks** after any ROM attempts → [GSI test template](docs/gsi-test-template.md)

### If you're a developer:
- TWRP porting for any MediaTek device here is the single biggest unlocker
- Kernel source requests to Tripltek (GPL compliance) — see [docs/kernel-source-request.md](docs/kernel-source-request.md)
- Device tree scaffolding once SoC is confirmed
- GSI compatibility patches

### Everyone:
- Open issues with device info, questions, or findings
- Share this repo on drone forums, XDA, Reddit r/LineageOS, r/androidroot

---

## Community Threads

- [XDA: Root for Tripltek Pro Tablet](https://xdaforums.com/t/root-for-tripletek-pro-tablet.4353163/) — has reports of LOS 20 GSI on T8 Pro
- Add yours via PR to [community/threads.md](community/threads.md)

---

## Important Warnings

- Unlocking the bootloader **voids your warranty**
- Tripltek's stock firmware includes **thermal limits for the display** — custom kernels that bypass these could damage your screen hardware
- Always **make a full backup** before attempting anything
- Tripltek does **not support** custom ROM attempts but has confirmed bootloader unlock is possible
- These are **industrial/professional devices** — proceed carefully

---

## Repo Structure

```
tripltek-lineageos/
├── devices/
│   ├── t7pro/          # Tripltek 7 Pro (primary focus)
│   ├── t8pro/          # Tripltek 8 Pro
│   ├── t9pro/          # Tripltek 9 Pro
│   ├── mini/           # Tripltek Mini (phone)
│   └── xpro/           # Tripltek X Pro (newest)
├── docs/               # Guides, templates, how-tos
├── tools/              # Useful scripts and utilities
└── community/          # Links, forum posts, contacts
```

---

## License

Documentation and scripts in this repo: MIT License.
Any device trees or kernel patches contributed here fall under GPL v2 as required by Linux/Android.

---

*This project is not affiliated with Tripltek. Tripltek is a trademark of its respective owner.*
