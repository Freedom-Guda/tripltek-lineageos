# Tripltek X Pro

> **Status: Newest device, lowest priority for now.** Micro-LED display, MTK AI chip — exotic enough that initial focus should stay on older models with broader installed base.

---

## Known Specs

| Item | Value |
|------|-------|
| Stock Android | TBD |
| Display | Micro-LED |
| SoC | MediaTek "AI" chip — model TBD (likely Dimensity tier) |
| RAM | TBD |
| Storage | TBD |
| Bootloader unlockable | Unknown |
| Treble support | Unknown |
| TWRP | Not yet ported |
| LineageOS GSI tested | Not yet |

---

## Why deprioritized

- Newest hardware → smallest installed base → fewest test devices
- Newer MediaTek SoCs have stricter verified-boot and may resist unlock more aggressively
- Micro-LED display likely has its own firmware/calibration layer that custom kernels could mishandle
- Best ROI is on the T7/T8 Pros where the community signal is strongest

---

## What we need from owners

If you happen to have one, the following are still genuinely useful even before any flashing attempts:

1. Full `getprop` dump
2. CPU-Z screenshot of the SoC tab
3. Treble Info screenshot
4. Bootloader unlock attempt — does Tripltek's procedure even work here?
5. Display info (`dumpsys SurfaceFlinger | head -100`) — Micro-LED panels may report unusual capabilities

---

## Special warning

The Micro-LED display is the most expensive component on this device. Any custom kernel that bypasses thermal or current limits could cause **permanent panel damage**. Do not flash anything on this device that has not been tested on a less expensive Tripltek first.
