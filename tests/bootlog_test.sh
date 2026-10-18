#!/usr/bin/env bash
# Tests tools/add-bootlog.sh and tools/read-bootlog.sh on small ext4 images. Run: tests/bootlog_test.sh
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

# A tiny stand-in for a system-as-root GSI image.
mkfs() { /usr/sbin/mke2fs -q -t ext4 -b 4096 "$1" 4096; }
mkfs "$WORK/gsi.img"
printf 'mkdir system\nmkdir system/bin\nmkdir system/etc\nmkdir system/etc/init\n' \
    | "$DEBUGFS" -w -f - "$WORK/gsi.img" >/dev/null 2>&1

out=$("$ROOT/tools/add-bootlog.sh" "$WORK/gsi.img" "$WORK/gsi-bootlog.img" 2>&1) || true
rc=$("$DEBUGFS" -R "stat /system/etc/init/tripltek_bootlog.rc" "$WORK/gsi-bootlog.img" 2>&1)
sh=$("$DEBUGFS" -R "stat /system/bin/tripltek_bootlog.sh" "$WORK/gsi-bootlog.img" 2>&1)
check "adds init service"           "$rc" "Mode:  0644"
check "adds executable script"      "$sh" "Mode:  0755"
check "files owned by root"         "$sh" "User:     0   Group:     0"
check "selinux label set"           "$("$DEBUGFS" -R "ea_list /system/bin/tripltek_bootlog.sh" "$WORK/gsi-bootlog.img" 2>&1)" 'u:object_r:system_file:s0\000'
check "service runs the script"     "$("$DEBUGFS" -R "cat /system/etc/init/tripltek_bootlog.rc" "$WORK/gsi-bootlog.img" 2>&1)" "/system/bin/tripltek_bootlog.sh"
check "original image untouched"    "$("$DEBUGFS" -R "ls /system/bin" "$WORK/gsi.img" 2>&1)" ".."
[ -n "$("$DEBUGFS" -R "ls /system/bin" "$WORK/gsi.img" 2>&1 | grep tripltek)" ] && check "original image untouched" "modified" "clean"

if out=$("$ROOT/tools/add-bootlog.sh" "$WORK/gsi.img" "$WORK/gsi.img" 2>&1); then out="unexpected success"; fi
check "refuses to overwrite input"  "$out" "must differ"

# A tiny stand-in for the cache partition after a logged boot.
mkfs "$WORK/cache.bin"
echo "hello dmesg" >"$WORK/dmesg.txt"
printf 'mkdir bootlog\nwrite %s bootlog/dmesg.txt\n' "$WORK/dmesg.txt" | "$DEBUGFS" -w -f - "$WORK/cache.bin" >/dev/null 2>&1
out=$("$ROOT/tools/read-bootlog.sh" "$WORK/cache.bin" "$WORK/logs" 2>&1) || true
check "extracts boot logs"          "$(cat "$WORK/logs/dmesg.txt" 2>&1)" "hello dmesg"

: >"$WORK/empty.bin"; mkfs "$WORK/empty.bin"
if out=$("$ROOT/tools/read-bootlog.sh" "$WORK/empty.bin" "$WORK/logs2" 2>&1); then out="unexpected success"; fi
check "explains missing logs"       "$out" "no /bootlog"

[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
