#!/usr/bin/env bash
# Tests tools/recon.sh against a fake adb. Run: tests/recon_test.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
T9PRO="$ROOT/tests/fixtures/t9pro_getprop.txt"
fails=0

# fake_adb STATE [GETPROP_FIXTURE] - adb stand-in reporting STATE from get-state.
# Every shell command it receives is logged to $WORK/cmds.log.
fake_adb() {
    : >"$WORK/cmds.log"
    cat >"$WORK/adb" <<SHIM
#!/usr/bin/env bash
case "\$1" in
    get-state)
        if [ "$1" = device ]; then echo device; else echo "error: $1" >&2; exit 1; fi ;;
    shell)
        printf '%s\n' "\$2" >>"$WORK/cmds.log"
        case "\$2" in
            getprop) cat "${2:-$T9PRO}" ;;
            "getprop ro.product.device") echo TRIPLTEK_T93 ;;
            "uname -a") printf 'Linux localhost 4.14.186-gcc225fdfa-dirty #1 SMP PREEMPT aarch64\r\n' ;;
            *) echo "fake: \$2" ;;
        esac ;;
esac
SHIM
    chmod +x "$WORK/adb"
}

check() { # NAME HAYSTACK NEEDLE
    if grep -qF -- "$3" <<<"$2"; then
        echo "ok   $1"
    else
        echo "FAIL $1: expected '$3' in:"; echo "$2" | sed 's/^/     /'
        fails=$((fails + 1))
    fi
}

run_recon() {
    ADB="$WORK/adb" OUT_ROOT="$WORK/out" "$ROOT/tools/recon.sh" 2>&1
}

# Fails if any logged command could change device state.
check_read_only() {
    local bad
    bad=$(grep -vE '^(getprop|uname|cat|ls|df|for f in|pm list|getenforce|zcat)( |$)' "$WORK/cmds.log" || true)
    bad+=$(grep -E '(^|[^0-9])>|reboot|setprop|settings put|svc |rm |dd |pm (install|uninstall|clear)' "$WORK/cmds.log" || true)
    check "sends only read-only commands" "${bad:-none}" "none"
}

fake_adb device
out=$(run_recon) || true
check "reports SoC"                 "$out" "MT6785V/CD"
check "reports Treble and VNDK"     "$out" "true (VNDK 31"
check "reports locked bootloader"   "$out" "locked (verified boot green)"
check "recommends GSI path"         "$out" "LineageOS GSI (arm64_bvN)"
check "strips CR from summary"      "CR count: $(grep -c $'\r' <<<"$out" || true)" "CR count: 0"
check "writes summary file"         "$(ls "$WORK"/out/TRIPLTEK_T93/*/ 2>&1)" "summary.txt"
check "keeps raw getprop"           "$(ls "$WORK"/out/TRIPLTEK_T93/*/ 2>&1)" "getprop.txt"
check_read_only

fake_adb device "$ROOT/tests/fixtures/t7pro_getprop.txt"
out=$(run_recon) || true
check "android 9: lock state from flash.locked" "$out" "Bootloader ......... locked"
check "android 9: absent A/B means no"          "$out" "A/B slots .......... false"
check "android 9: absent dynamic means no"      "$out" "Dynamic partitions . false"
check "android 9: reports system-as-root"       "$out" "System-as-root ..... true"

sed 's/^\[ro.product.cpu.abi\]: .*/[ro.product.cpu.abi]: [armeabi-v7a]/' "$T9PRO" >"$WORK/arm32.txt"
fake_adb device "$WORK/arm32.txt"
check "arm32 userspace on arm64 kernel" "$(run_recon || true)" "arm32_binder64"

: >"$WORK/empty.txt"
fake_adb device "$WORK/empty.txt"
check "missing props are not a 'no'" "$(run_recon || true)" "incomplete"

fake_adb unauthorized
if out=$(run_recon); then out="unexpected success"; fi
check "explains unauthorized"       "$out" "not authorized"

fake_adb "no permissions (user in plugdev group; are your udev rules wrong?)"
if out=$(run_recon); then out="unexpected success"; fi
check "explains udev permissions"   "$out" "udev"

fake_adb "no devices/emulators found"
if out=$(run_recon); then out="unexpected success"; fi
check "explains missing tablet"     "$out" "USB debugging"

[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
