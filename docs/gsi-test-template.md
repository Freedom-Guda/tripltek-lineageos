# GSI test report template

Copy this template into a new issue (or a PR adding to the device's `logs/` folder) any time you flash a Generic System Image and want to share what happened.

A test report is useful **even if it bricked**. The failure mode is data.

---

## Header

```
Device: [T7 Pro / T8 Pro / T9 Pro / Mini / X Pro]
Stock firmware version (ro.build.fingerprint): [paste]
Tripltek build date: [paste from About]
Bootloader unlocked: [yes / no / partial]
Vendor partition source: [stock / modified / unknown]
```

---

## GSI tested

```
GSI image:        [exact filename, e.g. lineage-20.0-20240101-UNOFFICIAL-arm64_bvN.img.xz]
Source URL:       [where you downloaded it]
SHA-256 of image: [run: sha256sum filename]
Treble variant:   [arm64 / arm64_bvN / arm64_bgN / a / a-only / etc.]
SELinux mode:     [enforcing / permissive / unknown]
```

---

## Flash procedure

Exact commands you ran, in order. Use a fenced code block:

```
fastboot flash system lineage-20.0...img
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
fastboot -w
fastboot reboot
```

Note any deviation from the obvious (e.g. you had to flash `vbmeta_system` separately, or you needed `--set-active=a`).

---

## Boot result

- [ ] Bootloops
- [ ] Boots to bootloader logo and stops
- [ ] Boots to recovery
- [ ] Boots to setup wizard
- [ ] Fully boots and is usable

If it boots, fill in the subsystem matrix below.

---

## Subsystem matrix

| Subsystem | Working | Notes |
|-----------|---------|-------|
| Wi-Fi | y/n/partial | |
| Bluetooth | y/n/partial | |
| Cellular data (Mini only) | y/n/partial | |
| Cellular voice / VoLTE (Mini only) | y/n/partial | |
| GPS | y/n/partial | |
| Camera (rear) | y/n/partial | |
| Camera (front) | y/n/partial | |
| Audio (speaker) | y/n/partial | |
| Audio (headphone jack) | y/n/partial | |
| Microphone | y/n/partial | |
| Touchscreen | y/n/partial | |
| Display brightness | y/n/partial | This is critical for Tripltek — they ship abnormally bright panels |
| Auto-brightness | y/n/partial | |
| Sensors (accelerometer / gyro / compass) | y/n/partial | |
| Fingerprint (if equipped) | y/n/partial | |
| Charging | y/n/partial | |
| Battery percentage accuracy | y/n/partial | |
| USB OTG | y/n/partial | |
| SD card | y/n/partial | |
| Encryption / decryption on first boot | y/n/partial | |
| Reboot to bootloader | y/n/partial | |
| Reboot to recovery | y/n/partial | |

---

## Logs

If anything broke, attach:

- `dmesg` from the running GSI (`adb shell dmesg > dmesg.txt`)
- `logcat` from boot (`adb logcat -d > logcat.txt`)
- Screenshot of the failure where applicable

---

## Recovery

How did you get back to a working state? This is the most useful section for the next person who tries this.

```
[describe recovery steps]
```

---

## Conclusion

One line: "GSI X on device Y, flash command Z, result was [bootloop / partial boot / fully usable but no camera] / etc."

That sentence is the single most valuable thing in the whole report.
