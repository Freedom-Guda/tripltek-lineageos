# Bootloader unlock

Tripltek support has confirmed that bootloader unlocking is **possible** on at least the T7 Pro. The exact procedure is not yet publicly documented in this repo. If you've gone through the process, please contribute notes via PR.

---

## What we know

- T7 Pro: confirmed unlockable per Tripltek support
- Other models: presumed unlockable, unconfirmed

---

## What we don't know

- Whether Tripltek requires you to email support for an unlock token, the way Xiaomi and OnePlus do
- Whether the standard `fastboot flashing unlock` works directly
- Whether unlocking trips a hardware fuse (Knox-style) that permanently invalidates warranty regardless of relocking
- Whether relocking is possible after unlock

---

## General MediaTek context

MediaTek devices typically follow one of these unlock paths:

1. **Standard fastboot path** (rare on consumer-grade MTK): `fastboot flashing unlock`
2. **MTK Auth Bypass** (common on older MTK chipsets): exploits in the BootROM allow unsigned image flashing via SP Flash Tool, regardless of bootloader lock state
3. **OEM-specific unlock token**: vendor sends you a `.bin` you flash via fastboot
4. **Locked permanently**: not the case here, since Tripltek confirmed unlock is possible

The MTK Auth Bypass route is particularly relevant because it works even on devices that don't expose a normal fastboot unlock command. Tools to look at:

- [bkerler/mtkclient](https://github.com/bkerler/mtkclient) — MTK BootROM tool, supports many MediaTek SoCs
- [MTKClient documentation](https://github.com/bkerler/mtkclient/wiki)

---

## Universal warnings

- **Unlocking wipes the device** in nearly all cases. Back up everything first.
- **Unlocking voids warranty** per Tripltek's stated policy.
- **First boot after unlock takes a long time.** Don't pull the cable.
- **Always note your serial number and current firmware version** before unlocking, in case you need to ask Tripltek for stock firmware later.

---

## Looking for: a real walkthrough

If you have actually unlocked a Tripltek device, please open a PR replacing this section with:

1. The exact fastboot or MTK tool commands you ran
2. Whether you needed to email Tripltek for a token
3. How long the unlock took
4. What state the device was in after (data wiped? bootloader warning shown? both?)
5. Whether you've successfully relocked

Anonymized, sanitized, no personal info.
