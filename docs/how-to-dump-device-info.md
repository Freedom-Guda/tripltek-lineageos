# How to dump device info

This is the single most useful thing any Tripltek owner can contribute, even if you never plan to flash anything. Five minutes of your time saves developers days of guessing.

---

## Prerequisites

- A Windows, macOS, or Linux PC
- A USB cable that supports data (not charge-only)
- Your Tripltek device

---

## Step 1: Enable Developer Options + USB Debugging

On your Tripltek:

1. **Settings → About tablet** (or About phone)
2. Tap **Build number** 7 times. You'll see "You are now a developer."
3. Back out, go to **Settings → System → Developer options**
4. Enable **USB debugging**
5. Plug into your PC. Accept the RSA fingerprint prompt on the device.

---

## Step 2: Install ADB on your PC

### Windows
Download Google's official platform-tools:
https://developer.android.com/tools/releases/platform-tools

Unzip somewhere stable like `C:\platform-tools\`. Open PowerShell or Command Prompt in that folder.

### macOS
```bash
brew install --cask android-platform-tools
```

### Linux
```bash
# Debian / Ubuntu
sudo apt install android-tools-adb
# Arch
sudo pacman -S android-tools
# Fedora
sudo dnf install android-tools
```

---

## Step 3: Verify the device is detected

```bash
adb devices
```

You should see something like:
```
List of devices attached
ABCD1234567890   device
```

If it shows `unauthorized`, accept the prompt on the device and try again. If empty, the cable is probably charge-only — try a different one.

---

## Step 4: Run the dump

The fastest path is the helper script in this repo:

### Windows
```cmd
tools\dump-device-info.bat > my-tripltek-dump.txt
```

### macOS / Linux
```bash
./tools/dump-device-info.sh > my-tripltek-dump.txt
```

If you don't want to clone the repo, run these commands manually and paste the output into a single file:

```bash
adb shell getprop > getprop.txt
adb shell cat /proc/cpuinfo > cpuinfo.txt
adb shell cat /proc/meminfo > meminfo.txt
adb shell cat /proc/partitions > partitions.txt
adb shell cat /proc/cmdline > cmdline.txt
adb shell ls -la /dev/block/by-name/ > partitions-by-name.txt
adb shell uname -a > kernel.txt
adb shell cat /vendor/build.prop > vendor-build.txt
adb shell df -h > storage.txt
```

---

## Step 5: Sanitize before posting

Before opening an issue, **search your dump file for:**

- Your serial number (`ro.serialno`, `ro.boot.serialno`)
- Your IMEI (Mini owners — `dumpsys telephony.registry` will contain this)
- Your Wi-Fi MAC (`ro.boot.wifimacaddr`)
- Your Bluetooth MAC (`ro.boot.btmacaddr`)
- Any account names

Replace them with `[REDACTED]`. None of those values are needed to port a ROM.

---

## Step 6: Open an issue

1. Go to the [Issues tab](../../issues)
2. Click **New issue → Device info dump**
3. Pick your device, paste the sanitized dump, submit

You're done. Thank you.

---

## Bonus: SoC confirmation via app

Even if you can't get ADB working, this still helps:

1. Install **CPU-Z** from Google Play
2. Open it, screenshot the **SoC** tab
3. Open an issue with the screenshot

That single screenshot tells us the exact MediaTek model number, which unblocks half the porting work.
