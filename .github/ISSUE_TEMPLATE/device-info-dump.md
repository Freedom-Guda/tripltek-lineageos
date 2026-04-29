---
name: Device info dump
about: Submit ADB / CPU-Z / Treble Info data from your Tripltek device
title: "[device-info] <T7 Pro / T8 Pro / T9 Pro / Mini / X Pro> — short note"
labels: device-info
assignees: ''
---

## Device

- Model: <T7 Pro / T8 Pro / T9 Pro / Mini / X Pro>
- Stock Android version:
- Build number / fingerprint (from About):

## What you're submitting

- [ ] `adb shell getprop` dump (paste below)
- [ ] CPU-Z screenshot (attach)
- [ ] Treble Info screenshot (attach)
- [ ] `/proc/partitions`, `/proc/cmdline`, `ls /dev/block/by-name/` (paste below)
- [ ] Other (describe):

## Sanitization checklist

Before submitting, please confirm you have redacted:

- [ ] Serial number (`ro.serialno`, `ro.boot.serialno`)
- [ ] IMEI (Mini only — search `dumpsys telephony.registry`)
- [ ] Wi-Fi MAC (`ro.boot.wifimacaddr`)
- [ ] Bluetooth MAC (`ro.boot.btmacaddr`)
- [ ] Any account names or email addresses

## Paste

<details>
<summary>getprop / partitions / etc</summary>

```
PASTE SANITIZED DUMP HERE
```

</details>
