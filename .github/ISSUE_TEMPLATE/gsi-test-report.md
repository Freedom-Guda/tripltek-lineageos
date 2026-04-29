---
name: GSI test report
about: Report what happened when you flashed a Generic System Image
title: "[gsi-test] <device> — <GSI variant> — <result>"
labels: gsi-test
assignees: ''
---

See [docs/gsi-test-template.md](../../docs/gsi-test-template.md) for the full template. Quick version below.

## Header

- Device:
- Stock fingerprint:
- Bootloader unlocked: yes / no / partial

## GSI

- Image filename:
- Source URL:
- SHA-256:
- Treble variant:

## Flash commands

```
PASTE EXACT COMMANDS YOU RAN
```

## Result

- [ ] Bootloops
- [ ] Stuck at bootloader logo
- [ ] Boots to recovery only
- [ ] Boots to setup wizard
- [ ] Fully boots and is usable

## Subsystem matrix

| Subsystem | Working | Notes |
|-----------|---------|-------|
| Wi-Fi | | |
| Bluetooth | | |
| Cellular (Mini) | | |
| GPS | | |
| Camera | | |
| Audio | | |
| Touchscreen | | |
| Display brightness | | |
| Sensors | | |
| Charging | | |

## Logs

Attach `dmesg.txt` and `logcat.txt` if you have them.

## Recovery steps

How did you get back to a working device?

```
DESCRIBE STEPS
```

## One-line summary

A single sentence that someone scanning this issue list can read in two seconds.
