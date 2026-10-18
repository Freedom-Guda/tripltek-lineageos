#!/usr/bin/env bash
# Read-only reconnaissance of a Tripltek tablet over adb.
#
# Nothing on the tablet is modified: every command only reads (getprop, cat, ls,
# pm list). Output lands in dumps/<device>/<UTC timestamp>/ and a porting summary
# is printed. dumps/ is gitignored because it holds serials and MAC addresses.
#
# Usage: tools/recon.sh                         one tablet plugged in
#        ANDROID_SERIAL=<serial> tools/recon.sh  several devices attached
set -euo pipefail

ADB=${ADB:-adb}
OUT_ROOT=${OUT_ROOT:-dumps}

die() { echo "ERROR: $*" >&2; exit 1; }

require_device() {
    command -v "$ADB" >/dev/null 2>&1 || die "adb not found in PATH"
    local state
    state=$("$ADB" get-state 2>&1) || true
    case "$state" in
        device) ;;
        *unauthorized*) die "tablet not authorized: unlock its screen and accept the 'Allow USB debugging' prompt" ;;
        *"more than one"*) die "several devices attached: set ANDROID_SERIAL (see 'adb devices')" ;;
        *"no permissions"*) die "no USB permission for the tablet: install udev rules (Ubuntu: sudo apt install android-sdk-platform-tools-common) and replug" ;;
        *offline*) die "tablet is offline: replug it, or run 'adb kill-server' and retry" ;;
        *) die "no tablet over adb: enable Settings > Developer options > USB debugging, then plug it in" ;;
    esac
}

# capture FILE 'device shell command' - stderr is kept so permission denials are visible.
capture() {
    "$ADB" shell "$2" </dev/null >"$OUT/$1" 2>&1 || echo "(exit status $?)" >>"$OUT/$1"
}

collect() {
    capture getprop.txt         'getprop'
    capture uname.txt           'uname -a'
    capture proc_version.txt    'cat /proc/version'
    capture cpuinfo.txt         'cat /proc/cpuinfo'
    capture meminfo.txt         'cat /proc/meminfo'
    capture cmdline.txt         'cat /proc/cmdline'
    capture partitions.txt      'cat /proc/partitions'
    capture by-name.txt         'ls -l /dev/block/by-name/ /dev/block/platform/bootdevice/by-name/'
    capture mounts.txt          'cat /proc/mounts'
    capture df.txt              'df -h'
    capture fstab.txt           'cat /vendor/etc/fstab.*'
    capture vintf_manifest.xml  'cat /vendor/etc/vintf/manifest.xml'
    capture devicetree.txt      'cat /sys/firmware/devicetree/base/model; echo; tr "\000" " " </sys/firmware/devicetree/base/compatible'
    capture input_devices.txt   'cat /proc/bus/input/devices'
    capture vendor_hw.txt       'ls -l /vendor/lib64/hw/ /vendor/lib/hw/'
    capture vendor_firmware.txt 'ls -l /vendor/firmware/'
    capture build_props.txt     'for f in /system/build.prop /vendor/build.prop /product/etc/build.prop /odm/etc/build.prop; do echo "== $f"; cat "$f"; done'
    capture packages.txt        'pm list packages -f'
    capture features.txt        'pm list features'
    capture selinux.txt         'getenforce'
    capture kernel_config.txt   'zcat /proc/config.gz'
}

# prop KEY - value of KEY from the captured getprop output, empty if absent.
prop() {
    awk -v k="[$1]:" '{ sub(/\r$/, "") } $1 == k { v = substr($0, length(k) + 3); sub(/\]$/, "", v); print v; exit }' \
        "$OUT/getprop.txt"
}

# first_prop KEY... - first non-empty value among KEYs, else "unknown".
first_prop() {
    local key val
    for key in "$@"; do
        val=$(prop "$key")
        if [ -n "$val" ]; then echo "$val"; return; fi
    done
    echo "unknown"
}

# flag_prop KEY - like prop, but absent means "false": builds only set these flags when true.
flag_prop() {
    local val
    val=$(prop "$1")
    echo "${val:-false}"
}

# Android 10+ reports vbmeta.device_state; Android 9 and older only flash.locked.
bootloader_state() {
    local state
    state=$(prop ro.boot.vbmeta.device_state)
    if [ -z "$state" ]; then
        case $(prop ro.boot.flash.locked) in
            1) state=locked ;;
            0) state=unlocked ;;
            *) state=unknown ;;
        esac
    fi
    echo "$state"
}

# Only meaningful up to Android 9; Android 10+ always boots system as root via two-stage init.
sar_state() {
    local sar sdk
    sar=$(prop ro.build.system_root_image)
    sdk=$(prop ro.build.version.sdk)
    if [ -n "$sar" ]; then
        echo "$sar"
    elif [[ "$sdk" =~ ^[0-9]+$ ]] && [ "$sdk" -ge 29 ]; then
        echo "n/a (Android 10+)"
    else
        echo "false"
    fi
}

ab_state() {
    if [ "$(flag_prop ro.build.ab_update)" = true ]; then
        echo "true (slot $(first_prop ro.boot.slot_suffix), virtual A/B $(flag_prop ro.virtual_ab.enabled))"
    else
        echo "false"
    fi
}

verdict() {
    local treble=$1 abi=$2 kernel=$3
    if [ "$treble" = "unknown" ]; then
        echo "Recon incomplete: no usable getprop output. Check $OUT/getprop.txt and rerun."
    elif [ "$treble" != "true" ]; then
        echo "No Treble: a GSI will not boot. Needs a full device tree (much harder)."
    elif [ "$abi" = "arm64-v8a" ]; then
        echo "Treble arm64: LineageOS GSI (arm64_bvN) is the fast path once the bootloader is unlocked."
    elif [[ "$kernel" == *aarch64* ]]; then
        echo "Treble, 32-bit userspace on a 64-bit kernel: use an arm32_binder64 (a64_bvN) LineageOS GSI."
    else
        echo "Treble, fully 32-bit ($abi): use an arm32 (arm_bvN) LineageOS GSI."
    fi
}

summarize() {
    local treble abi kernel
    treble=$(first_prop ro.treble.enabled)
    abi=$(first_prop ro.product.cpu.abi)
    kernel=$(head -n1 "$OUT/uname.txt" | tr -d '\r')
    cat <<EOF

Tripltek recon summary ($(date -u +%Y-%m-%dT%H:%M:%SZ))
Model .............. $(first_prop ro.product.model) ($(first_prop ro.product.device ro.build.product))
Build .............. $(first_prop ro.build.display.id)
Android ............ $(first_prop ro.build.version.release) (SDK $(first_prop ro.build.version.sdk)), patch $(first_prop ro.build.version.security_patch), vendor patch $(first_prop ro.vendor.build.security_patch)
SoC ................ $(first_prop ro.soc.model ro.vendor.mediatek.platform ro.board.platform) (platform $(first_prop ro.board.platform), hardware $(first_prop ro.hardware))
Kernel ............. $kernel
CPU ABI ............ $abi
Treble ............. $treble (VNDK $(first_prop ro.vndk.version ro.product.vndk.version), first API $(first_prop ro.product.first_api_level))
A/B slots .......... $(ab_state)
Dynamic partitions . $(flag_prop ro.boot.dynamic_partitions)
System-as-root ..... $(sar_state)
Bootloader ......... $(bootloader_state) (verified boot $(first_prop ro.boot.verifiedbootstate))
OEM unlock toggle .. supported=$(first_prop ro.oem_unlock_supported) enabled=$(first_prop sys.oem_unlock_allowed)

Verdict: $(verdict "$treble" "$abi" "$kernel")
Raw data: $OUT
EOF
}

main() {
    require_device
    local device
    device=$("$ADB" shell 'getprop ro.product.device' </dev/null | tr -d '\r') \
        || die "lost the tablet while reading its model name; replug and retry"
    device=${device%%$'\n'*}
    device=$(printf '%s' "$device" | tr -c 'A-Za-z0-9._-' '_')
    [[ "$device" =~ ^\.*$ ]] && device=unknown   # empty, ".", ".." would escape OUT_ROOT
    OUT="$OUT_ROOT/$device/$(date -u +%Y%m%dT%H%M%SZ)"
    mkdir -p "$OUT"
    echo "Reading $device into $OUT (read-only, nothing is changed)..." >&2
    collect
    summarize | tee "$OUT/summary.txt"
}

main "$@"
