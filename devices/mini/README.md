# Tripltek Mini

> **Status: Untested.** Phone form factor, less common than the tablets.

---

## Known Specs

| Item | Value |
|------|-------|
| Stock Android | 12 |
| Form factor | Phone |
| SoC | MediaTek (model TBD) |
| RAM | TBD |
| Storage | TBD |
| Bootloader unlockable | Unknown |
| Treble support | Unknown |
| TWRP | Not yet ported |
| LineageOS GSI tested | Not yet |

---

## Notes

The Mini is a phone, not a tablet, which means it ships with modem/baseband firmware. That changes the GSI story:

- A booting GSI may lose cellular voice/data even if Wi-Fi works
- Vendor blobs for the modem are usually the hardest part to keep working
- If the device is Treble-compliant, voice over LTE / VoLTE is the most fragile subsystem

---

## What we need from owners

1. Full `getprop` dump
2. CPU-Z screenshot
3. Treble Info screenshot
4. Carrier(s) used — VoLTE behavior on stock will help us predict what GSI breaks
5. IMS / VoLTE config from `dumpsys telephony.registry` (sanitize IMEI before posting)

---

## Current blockers

- Smaller installed base means fewer test devices
- Phone-specific subsystems (modem, IMS, telephony) raise the difficulty bar above the tablets
