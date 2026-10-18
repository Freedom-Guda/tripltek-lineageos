# Tripltek LineageOS Project

> **Community effort to bring LineageOS (and other custom ROMs) to all Tripltek devices.**

Tripltek makes some of the brightest, most rugged Android tablets on the market — favored by drone pilots, field workers, and outdoor professionals. But their devices ship with outdated Android versions, no security updates, and no path to a modern OS. This project aims to fix that.

> **First result:** the **T7 Pro runs LineageOS 19.1 (Android 12L)** as a daily driver.
> Recipe, what works, and the debugging story are in [devices/t7pro](devices/t7pro/).

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
| [T7 Pro](devices/t7pro/) | Android 9 | **MT6771** (Helio P60/P70) | **Yes** (`fastboot flashing unlock`, tested) | Yes, VNDK 28 | None | **LOS 19.1 boots, daily use** (GPS lib patch) | LOS 20 blocked by FDE + kernel 4.4 |
| [T8 Pro](devices/t8pro/) | Android 10 | MTK (model TBD) | Likely | Unknown | None | LOS 20 GSI boots w/ issues | XDA reports partial success |
| [T9 Pro](devices/t9pro/) | Android 12 | **MT6785V/CD** (Helio G90T/G95 family) | Yes (OEM unlocking exposed) | Yes, VNDK 31 | None | Untested | Kernel 4.14 + FBE: good LOS 21 candidate |
| [Mini](devices/mini/) | Android 12 | MTK (model TBD) | Unknown | Unknown | None | Untested | Phone form factor |
| [X Pro](devices/xpro/) | Android (TBD) | MTK AI chip (model TBD) | Unknown | Unknown | None | Untested | Newest, Micro-LED |

---

## How to Contribute

You don't need to be a developer to help. Every Tripltek owner can contribute:

### If you own any Tripltek device:
1. **Run `tools/recon.sh`** (read-only; it changes nothing on the tablet) or `adb shell getprop`, redact the serial and MACs, and submit the output → [info dump template](docs/how-to-dump-device-info.md)
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

## Tools

Bash scripts for Linux, each tested against fakes (`for t in tests/*_test.sh; do $t; done`).

| Script | What it does | Writes to the tablet? |
|--------|--------------|-----------------------|
| `tools/recon.sh` | adb survey: model, SoC, Treble/VNDK, A/B, partitions, lock state, GSI verdict | no |
| `tools/backup.sh` | Full BROM dump via mtkclient: GPT, preloader, every partition except userdata | no |
| `tools/verify-backup.sh` | Checks each image against the GPT sizes, writes SHA256SUMS | — |
| `tools/patch-vndk.sh` | Swaps MediaTek-modified VNDK libs from stock into a GSI (fixes HALs that won't link) | — |
| `tools/flash-gsi.sh` | Guarded GSI flash: checks unlock state, product, image size and battery voltage | **yes** |
| `tools/add-bootlog.sh` / `read-bootlog.sh` | Debug image that logs a hung boot to `/cache`, plus the extractor | **yes** (when flashed) |
| `tools/thermal-watch.sh` | Root: samples real backlight level, temperatures and backlight coolers to CSV | no |
| `tools/re/` | `mtc_decode.py` (MTK thermal policy), `unpack_boot.py`, `fdtdump.py`, `arsc_arrays.py` | — |

mtkclient setup: `git clone https://github.com/bkerler/mtkclient third_party/mtkclient`, check out a release tag,
run `uv sync --frozen` inside it, and copy `Setup/Linux/52-mtk.rules` to `/etc/udev/rules.d/`. Stop ModemManager
(`sudo systemctl stop ModemManager`) before BROM work.

---

## Community Threads

- [XDA: Root for Tripltek Pro Tablet](https://xdaforums.com/t/root-for-tripletek-pro-tablet.4353163/) — has reports of LOS 20 GSI on T8 Pro
- Add yours via PR to [community/threads.md](community/threads.md)

---

## Important Warnings

- Unlocking the bootloader **voids your warranty**
- **Display heat:** on the T7 Pro we found **no** firmware-level display thermal limit ([details](devices/t7pro/#display-brightness-and-thermal)). The backlight's protection is in the PMIC hardware, and a GSI keeps the stock kernel and vendor. Other models are unverified, so be most careful with the X Pro's Micro-LED panel, and keep stock backlight settings in any custom kernel
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
├── tools/              # Scripts (see Tools above); re/ = reverse-engineering helpers, bootlog/ = debug logger
├── tests/              # Tests for tools/, run with fakes (no tablet needed)
└── community/          # Links, forum posts, contacts
```

---

## License

Documentation and scripts in this repo: MIT License.
Any device trees or kernel patches contributed here fall under GPL v2 as required by Linux/Android.

---

*This project is not affiliated with Tripltek. Tripltek is a trademark of its respective owner.*
