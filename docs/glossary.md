# Glossary

Quick definitions of terms used throughout this repo. Aimed at Tripltek owners who want to help but are new to Android modding.

---

**A/B partitions** — modern Android scheme where the device has two copies of system, vendor, etc. so updates can install to the inactive slot and switch over on reboot. The alternative is "A-only".

**ADB (Android Debug Bridge)** — Google's command-line tool for talking to an Android device over USB or Wi-Fi. Required for almost everything in this repo.

**AOSP (Android Open Source Project)** — Google's upstream Android source. LineageOS is built on top of AOSP.

**Bootloader** — the first piece of software that runs when the device powers on. It loads the kernel. "Unlocking the bootloader" means allowing it to load kernels and recoveries that aren't signed by the manufacturer.

**Custom recovery** — a replacement for the stock Android recovery partition that lets you flash arbitrary images, make full backups, and run shell commands. TWRP and OrangeFox are the two big ones.

**Device tree** — a folder of configuration files in the LineageOS build system that describes a specific phone or tablet (which kernel to use, which proprietary blobs, what partitions look like, etc.). Required for an "official" port.

**Fastboot** — a low-level mode the device boots into when you hold a key combo on power-up, used for flashing partitions directly from a PC.

**GSI (Generic System Image)** — a Treble-compatible system image that should boot on any compliant device. The fastest way to test if LineageOS will work at all.

**Kernel source** — the modified Linux kernel that runs on the device. Manufacturers must release this under GPL v2 on request.

**LineageOS** — the most popular community Android distribution. The successor to CyanogenMod.

**MediaTek (MTK)** — the chipmaker. Tripltek uses MediaTek SoCs across the lineup. MTK chips have a reputation for being harder to mod than Qualcomm — fewer official sources, more reverse engineering.

**MTK Auth Bypass** — a class of BootROM exploits that allow unsigned image flashing on many MediaTek devices, sometimes regardless of bootloader lock state.

**OTA (Over-The-Air update)** — the manufacturer's update mechanism. Custom ROMs almost always disable this.

**Partition** — a logical slice of the device's flash storage. Important ones for ROM work: `boot`, `recovery`, `system`, `vendor`, `userdata`, `vbmeta`.

**Project Treble** — Google's architecture (introduced in Android 8) that separates the OS from the vendor implementation, allowing GSI flashing on compliant devices.

**Relock** — restoring bootloader lock after having unlocked it. Some devices won't boot a stock ROM after relock if vbmeta is dirty.

**SoC (System on Chip)** — the main processor package. For Tripltek, always MediaTek, but the exact model matters enormously (MT6765 vs MT6873 vs Helio G76 are very different beasts).

**SP Flash Tool** — MediaTek's official Windows tool for flashing scatter files. Used for stock recovery.

**Stock firmware** — the manufacturer's original software. You want a copy before you do anything risky.

**TWRP (Team Win Recovery Project)** — the most-used custom recovery. A device with TWRP available is a much easier target for ROM porting.

**vbmeta** — Android Verified Boot metadata. Custom ROMs typically need this disabled or replaced.

**Vendor blobs** — proprietary binary drivers (camera, modem, GPU, sensors) that the manufacturer provides and that can't be open-sourced. Compatible blobs are usually the gating factor for whether a GSI works.
