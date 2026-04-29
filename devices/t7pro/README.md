# Tripltek 7 Pro

> **Status: Active focus.** Bootloader unlock confirmed possible by Tripltek. SoC and Treble status need confirmation from owners.

The T7 Pro is the oldest still-shipping Tripltek tablet and the highest-priority target for this project. It has the largest installed base, the most outdated Android version (9), and the best community signal so far.

---

## Known Specs

| Item | Value |
|------|-------|
| Stock Android | 9 |
| Display | 7" high-brightness LCD |
| SoC | MediaTek (model TBD — need CPU-Z dump) |
| RAM | TBD |
| Storage | TBD |
| Bootloader unlockable | Yes (confirmed by Tripltek support) |
| Treble support | Unknown |
| TWRP | Not yet ported |
| LineageOS GSI tested | Not yet |

---

## What we need from owners

If you have a T7 Pro, any one of these is genuinely useful:

1. **`adb shell getprop` dump** — see [docs/how-to-dump-device-info.md](../../docs/how-to-dump-device-info.md)
2. **CPU-Z screenshot** of the SoC tab (confirms MediaTek model number, e.g. MT6765, MT6771, MT8788)
3. **Treble Info app** screenshot
4. **`/proc/partitions` dump** (helps map A/B vs A-only and partition layout)
5. **Bootloader unlock walkthrough** if you've gone through Tripltek's process — even rough notes help

Open an issue with the `device-info` label and dump whatever you have.

---

## Current blockers

- **SoC unconfirmed** — without the exact MediaTek chip we can't pull the right kernel branch or look up known device trees
- **No TWRP** — recovery porting is the gating step for almost everything else
- **Kernel source not requested** — Tripltek is GPL-bound to provide it; nobody has formally asked yet, see [docs/kernel-source-request.md](../../docs/kernel-source-request.md)

---

## Roadmap (proposed)

1. Confirm SoC + partition layout from owner dumps
2. File GPL kernel source request with Tripltek
3. Port TWRP (most likely route: adapt an existing tree for the same MediaTek SoC)
4. Test LineageOS GSI on Treble (if supported) for a quick win
5. Build a proper device tree once kernel source lands
6. Submit to LineageOS unofficial / official tracks

---

## Logs

Once owners start submitting test reports, they go in [logs/](logs/) (not yet created — first contributor wins).
