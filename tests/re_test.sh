#!/usr/bin/env bash
# Tests the reverse-engineering helpers in tools/re/. Run: tests/re_test.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
fails=0

check() { # NAME HAYSTACK NEEDLE
    if grep -qF -- "$3" <<<"$2"; then
        echo "ok   $1"
    else
        echo "FAIL $1: expected '$3' in:"; echo "$2" | sed 's/^/     /'
        fails=$((fails + 1))
    fi
}

# Real lines from the T7 Pro's /vendor/etc/.tp/thermal.conf
out=$(python3 -I "$ROOT/tools/re/mtc_decode.py" "$ROOT/tests/fixtures/thermal_sample.mtc")
check "decodes section header"   "$out" "Sec_Chip_Name"
check "decodes chip name"        "$out" "MT6771"
check "decodes cooler path"      "$out" "/proc/mtkcooler/mtktscpu-sysrst"
check "decodes exit threshold"   "$out" "EXIT 6000"

[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
