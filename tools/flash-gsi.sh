#!/usr/bin/env bash
# Flash a GSI system image onto an unlocked Tripltek tablet in bootloader fastboot.
#
# Refuses unless: exactly one fastboot device, bootloader unlocked, product matches
# EXPECTED_PRODUCT, and the raw image fits the system partition. Then flashes system,
# erases userdata/cache (unless --keep-data) and reboots.
#
# Usage: tools/flash-gsi.sh IMAGE.img [--keep-data]
#        EXPECTED_PRODUCT=<fastboot product> tools/flash-gsi.sh ...   (other models)
set -euo pipefail

FASTBOOT=${FASTBOOT:-fastboot}
EXPECTED_PRODUCT=${EXPECTED_PRODUCT:-soten6771_p_t71v4}   # Tripltek 7 Pro (T7121)
MIN_BATTERY_MV=${MIN_BATTERY_MV:-3800}   # 3944 mV flashed fine; 3601 mV aborted mid-flash

die() { echo "ERROR: $*" >&2; exit 1; }

# getvar NAME - value of a fastboot variable (fastboot prints "name: value" on stderr),
# empty if the bootloader doesn't know it (fastboot then exits non-zero).
getvar() { "$FASTBOOT" getvar "$1" 2>&1 | sed -n "s/^$1: *//p" | head -n1 || true; }

IMAGE=${1:?usage: tools/flash-gsi.sh IMAGE.img [--keep-data]}
WIPE=true
[ "${2:-}" = "--keep-data" ] && WIPE=false

case "$IMAGE" in
    *.gz|*.xz|*.zip) die "decompress $IMAGE first (gunzip/unxz); fastboot needs the raw .img" ;;
esac
[ -f "$IMAGE" ] || die "no such image: $IMAGE"

devices=$("$FASTBOOT" devices | grep -c . || true)
[ "$devices" -eq 1 ] || die "need exactly one device in fastboot, found $devices (run: adb reboot bootloader)"

[ "$(getvar unlocked)" = yes ] || die "bootloader is not unlocked (fastboot flashing unlock)"

product=$(getvar product)
[ "$product" = "$EXPECTED_PRODUCT" ] \
    || die "device reports product '$product', expected '$EXPECTED_PRODUCT' (set EXPECTED_PRODUCT for another model)"

# MediaTek lk prints the size as bare hex ("c0000000"); others use "0x...".
part_hex=$(getvar partition-size:system)
part_hex=${part_hex#0x}
[[ "$part_hex" =~ ^[0-9a-fA-F]+$ ]] || die "could not read system partition size (got '$part_hex')"
part_size=$((16#$part_hex))
img_size=$(stat -c %s "$IMAGE")
[ "$img_size" -le "$part_size" ] \
    || die "image ($img_size bytes) does not fit the system partition ($part_size bytes)"

# MediaTek lk refuses writes mid-flash when the battery sags under load
# ("low power, need battery charging"), leaving system half-written. Its reading
# is taken once at boot, so check it up front.
volts=$(getvar battery-voltage)
volts=${volts%mV}
if [[ "$volts" =~ ^[0-9]+$ ]] && [ "$volts" -lt "$MIN_BATTERY_MV" ]; then
    die "battery too low for flashing (${volts} mV < ${MIN_BATTERY_MV} mV). Charge it, then reboot to fastboot so the bootloader re-reads it"
fi

echo "Flashing $IMAGE ($img_size bytes) to system on $product..."
"$FASTBOOT" flash system "$IMAGE"
if $WIPE; then
    # Erase, not -w: -w formats on the host with mke2fs, which fails with some
    # distro builds. The fstab marks both partitions formattable, so Android
    # formats them on first boot.
    echo "Erasing userdata and cache (a GSI needs a clean /data)..."
    "$FASTBOOT" erase userdata
    "$FASTBOOT" erase cache
fi
"$FASTBOOT" reboot
echo "Done. First boot of a GSI can take 5-10 minutes."
