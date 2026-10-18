#!/usr/bin/env bash
# Tests tools/flash-gsi.sh against a fake fastboot. Run: tests/flash_gsi_test.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
fails=0

# fake_fastboot UNLOCKED PRODUCT SYSTEM_SIZE_HEX [BATTERY_VOLTAGE] - logs every call to $WORK/calls.log
fake_fastboot() {
    : >"$WORK/calls.log"
    cat >"$WORK/fastboot" <<SHIM
#!/usr/bin/env bash
echo "\$*" >>"$WORK/calls.log"
case "\$*" in
    devices) printf 'TESTSERIAL1\tfastboot\n' ;;
    "getvar unlocked") echo "unlocked: $1" >&2 ;;
    "getvar product") echo "product: $2" >&2 ;;
    "getvar partition-size:system") echo "partition-size:system: $3" >&2 ;;
    "getvar battery-voltage") [ -n "${4-3944mV}" ] && echo "battery-voltage: ${4-3944mV}" >&2 ;;
esac
SHIM
    chmod +x "$WORK/fastboot"
}

check() { # NAME HAYSTACK NEEDLE
    if grep -qF -- "$3" <<<"$2"; then
        echo "ok   $1"
    else
        echo "FAIL $1: expected '$3' in:"; echo "$2" | sed 's/^/     /'
        fails=$((fails + 1))
    fi
}

flash() { FASTBOOT="$WORK/fastboot" "$ROOT/tools/flash-gsi.sh" "$@" </dev/null 2>&1; }

truncate -s 1000 "$WORK/gsi.img"

fake_fastboot yes soten6771_p_t71v4 2000
out=$(flash "$WORK/gsi.img") || true
calls=$(cat "$WORK/calls.log")
check "flashes system"              "$calls" "flash system $WORK/gsi.img"
after=$(sed -n '/^flash system/,$p' "$WORK/calls.log")
check "erases userdata after flash" "$after" "erase userdata"
check "erases cache after flash"    "$after" "erase cache"
check "avoids host-side format -w"  "$(grep -c '^-w' "$WORK/calls.log" || true)" "0"
check "reboots last"                "$(tail -n1 "$WORK/calls.log")" "reboot"

fake_fastboot yes soten6771_p_t71v4 0x2000
flash "$WORK/gsi.img" --keep-data >/dev/null || true
check "--keep-data skips wipe"      "$(grep -c '^erase' "$WORK/calls.log" || true)" "0"

fake_fastboot no soten6771_p_t71v4 0x2000
if out=$(flash "$WORK/gsi.img"); then out="unexpected success"; fi
check "refuses locked bootloader"   "$out" "not unlocked"
check "nothing flashed when locked" "$(grep -c '^flash' "$WORK/calls.log" || true)" "0"

fake_fastboot yes some_other_board 0x2000
if out=$(flash "$WORK/gsi.img"); then out="unexpected success"; fi
check "refuses other device"        "$out" "some_other_board"

fake_fastboot yes soten6771_p_t71v4 100
if out=$(flash "$WORK/gsi.img"); then out="unexpected success"; fi
check "refuses oversize image"      "$out" "does not fit"

fake_fastboot yes soten6771_p_t71v4 0x2000
if out=$(flash "$WORK/gsi.img.gz"); then out="unexpected success"; fi
check "refuses compressed image"    "$out" "decompress"

fake_fastboot yes soten6771_p_t71v4 2000 3601mV
if out=$(flash "$WORK/gsi.img"); then out="unexpected success"; fi
check "refuses low battery"         "$out" "battery"
check "nothing flashed on low batt" "$(grep -c '^flash' "$WORK/calls.log" || true)" "0"

fake_fastboot yes soten6771_p_t71v4 2000 ""
flash "$WORK/gsi.img" >/dev/null || true
check "no voltage var still flashes" "$(cat "$WORK/calls.log")" "flash system"

[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
