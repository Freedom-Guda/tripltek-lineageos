# Bootloader unlock

**T7 Pro: done, standard AOSP path, no token.** Walkthrough below (2026-10-17, one unit, stock T7121-20210420).
Other models are presumed similar; the T9 Pro also exposes the OEM unlocking toggle.

---

## T7 Pro walkthrough

1. **Back up first.** Unlocking erases userdata. A full BROM backup works with the bootloader locked:
   `tools/backup.sh` (see [devices/t7pro](../devices/t7pro/)).
2. Settings → About tablet → tap **Build number** 7×. Then Settings → System → Developer options:
   turn on **OEM unlocking** (needs your PIN) and **USB debugging**. Check: `adb shell getprop sys.oem_unlock_allowed` → `1`.
3. `adb reboot bootloader` (a small "FASTBOOT mode" text appears). `fastboot getvar unlocked` → `no`.
4. `fastboot flashing unlock`, then press **Volume Up** on the tablet to confirm (Volume Down cancels).
5. It takes seconds. Afterwards `fastboot getvar unlocked` → `yes` and `secure` → `no`.
6. `fastboot reboot`. Every boot now shows an orange "device is unlocked" warning for a few seconds, and
   Android reports `ro.boot.verifiedbootstate=orange` and `ro.boot.flash.locked=0`. Userdata is wiped.

Boot-menu fallback (when adb isn't available): power off, then hold **Volume Up + Power** → boot menu →
Volume Up to move to *Fastboot Mode*, Volume Down to select.

---

## Still unknown

- Whether unlocking trips a hardware fuse (Knox-style). Nothing observed on the T7 Pro beyond the orange state
- Whether relocking works (`fastboot flashing lock`). Untested; relock only with **stock** system/boot/vendor
  flashed back, or the tablet won't boot

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
