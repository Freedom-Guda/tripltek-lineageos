#!/usr/bin/env bash
# Tests tools/patch-vndk.sh on a small ext4 image. Run: tests/patch_vndk_test.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
DEBUGFS=/usr/sbin/debugfs
fails=0

check() { # NAME HAYSTACK NEEDLE
    if grep -qF -- "$3" <<<"$2"; then
        echo "ok   $1"
    else
        echo "FAIL $1: expected '$3' in:"; echo "$2" | sed 's/^/     /'
        fails=$((fails + 1))
    fi
}

# GSI stand-in with a flattened VNDK v28 APEX holding the "wrong" libfoo.so
/usr/sbin/mke2fs -q -t ext4 -b 4096 "$WORK/gsi.img" 4096
echo old >"$WORK/old.so"
A=system/system_ext/apex/com.android.vndk.v28
"$DEBUGFS" -w -f - "$WORK/gsi.img" >/dev/null 2>&1 <<CMDS
mkdir system
mkdir system/system_ext
mkdir system/system_ext/apex
mkdir $A
mkdir $A/lib
mkdir $A/lib64
write $WORK/old.so $A/lib/libfoo.so
write $WORK/old.so $A/lib64/libfoo.so
CMDS

# Stock system stand-in (layout of the extracted stock system image)
mkdir -p "$WORK/stock/system/lib/vndk-28" "$WORK/stock/system/lib64/vndk-28"
echo stock32 >"$WORK/stock/system/lib/vndk-28/libfoo.so"
echo stock64 >"$WORK/stock/system/lib64/vndk-28/libfoo.so"

patch() { "$ROOT/tools/patch-vndk.sh" "$@" 2>&1; }

out=$(patch "$WORK/gsi.img" "$WORK/out.img" "$WORK/stock" 28 libfoo.so) || true
check "replaces 64-bit lib"        "$("$DEBUGFS" -R "cat /$A/lib64/libfoo.so" "$WORK/out.img" 2>&1)" "stock64"
check "replaces 32-bit lib"        "$("$DEBUGFS" -R "cat /$A/lib/libfoo.so" "$WORK/out.img" 2>&1)" "stock32"
check "keeps mode and owner"       "$("$DEBUGFS" -R "stat /$A/lib64/libfoo.so" "$WORK/out.img" 2>&1)" "Mode:  0644"
check "sets system_lib_file label" "$("$DEBUGFS" -R "ea_list /$A/lib64/libfoo.so" "$WORK/out.img" 2>&1)" 'u:object_r:system_lib_file:s0\000'
check "input image untouched"      "$("$DEBUGFS" -R "cat /$A/lib64/libfoo.so" "$WORK/gsi.img" 2>&1)" "old"

if out=$(patch "$WORK/gsi.img" "$WORK/out2.img" "$WORK/stock" 28 libmissing.so); then out="unexpected success"; fi
check "refuses libs not in the APEX" "$out" "libmissing.so"

if out=$(patch "$WORK/gsi.img" "$WORK/gsi.img" "$WORK/stock" 28 libfoo.so); then out="unexpected success"; fi
check "refuses to overwrite input" "$out" "must differ"

[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
