#!/usr/bin/env bash
# Tests tools/thermal-watch.sh against a fake adb. Run: tests/thermal_watch_test.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
fails=0

# fake_adb UID - adb stand-in whose su reports UID; logs every shell command.
fake_adb() {
    : >"$WORK/cmds.log"
    cat >"$WORK/adb" <<SHIM
#!/usr/bin/env bash
[ "\$1" = shell ] || exit 0
printf '%s\n' "\$2" >>"$WORK/cmds.log"
case "\$2" in
    "su -c 'id -u'") echo "$1" ;;
    "settings get system screen_brightness") echo 255 ;;
    *cdev*) echo "mtktsAP -> mtk-cl-backlight00 (trip 2)" ;;
    *lcd-backlight*) printf '180,48000,47000,36000,1\r\n' ;;
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

run_watch() {
    ADB="$WORK/adb" OUT_ROOT="$WORK/out" DEVICE=T7121 "$ROOT/tools/thermal-watch.sh" 1 1 2>&1
}

fake_adb 0
out=$(run_watch) || true
csv=$(cat "$WORK"/out/T7121/thermal-*.csv 2>&1 || true)
check "lists backlight cooler bindings" "$out" "mtktsAP -> mtk-cl-backlight00"
check "writes CSV header"               "$csv" "time_s,framework_brightness,kernel_backlight,ap_mC,cpu_mC,battery_mC,backlight_cooler_sum"
check "records framework and kernel"    "$csv" ",255,180,48000,47000,36000,1"
check "strips CR from samples"          "CR count: $(grep -c $'\r' <<<"$csv" || true)" "CR count: 0"
bad=$(grep -E '>[[:space:]]*/(sys|proc|data|dev)|setprop|settings put|reboot|rm ' "$WORK/cmds.log" || true)
check "sends only read-only commands"   "${bad:-none}" "none"

fake_adb 2000
if out=$(run_watch); then out="unexpected success"; fi
check "explains missing root"           "$out" "no root"

[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
