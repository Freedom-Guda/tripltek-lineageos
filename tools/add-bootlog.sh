#!/usr/bin/env bash
# Make a debug copy of a system-as-root GSI image that snapshots boot logs into
# /cache/bootlog (see tools/bootlog/). Use it when a GSI hangs before adb comes up:
# flash the copy, let it hang for a few minutes, read the cache partition over BROM
# (mtkclient r cache cache.bin), then run tools/read-bootlog.sh on it.
#
# Usage: tools/add-bootlog.sh IN.img OUT.img
set -euo pipefail

DEBUGFS=${DEBUGFS:-/usr/sbin/debugfs}
SRC=$(cd "$(dirname "$0")/bootlog" && pwd)

die() { echo "ERROR: $*" >&2; exit 1; }

IN=${1:?usage: tools/add-bootlog.sh IN.img OUT.img}
OUT=${2:?usage: tools/add-bootlog.sh IN.img OUT.img}
[ -f "$IN" ] || die "no such image: $IN"
[ "$(realpath -m "$IN")" != "$(realpath -m "$OUT")" ] || die "IN and OUT must differ (the original is kept clean)"
[ -x "$DEBUGFS" ] || die "debugfs not found at $DEBUGFS (install e2fsprogs)"

cp --reflink=auto "$IN" "$OUT"
ctx=$(mktemp)
trap 'rm -f "$ctx"' EXIT
printf 'u:object_r:system_file:s0\0' >"$ctx"   # Android stores labels NUL-terminated

"$DEBUGFS" -w -f - "$OUT" >/dev/null 2>&1 <<CMDS
write $SRC/tripltek_bootlog.sh /system/bin/tripltek_bootlog.sh
write $SRC/tripltek_bootlog.rc /system/etc/init/tripltek_bootlog.rc
sif /system/bin/tripltek_bootlog.sh mode 0100755
sif /system/etc/init/tripltek_bootlog.rc mode 0100644
sif /system/bin/tripltek_bootlog.sh uid 0
sif /system/bin/tripltek_bootlog.sh gid 0
sif /system/etc/init/tripltek_bootlog.rc uid 0
sif /system/etc/init/tripltek_bootlog.rc gid 0
ea_set -f $ctx /system/bin/tripltek_bootlog.sh security.selinux
ea_set -f $ctx /system/etc/init/tripltek_bootlog.rc security.selinux
CMDS

"$DEBUGFS" -R "stat /system/etc/init/tripltek_bootlog.rc" "$OUT" 2>/dev/null | grep -q 'Mode:  0644' \
    || die "injection failed (image full or not a system-as-root layout?)"
echo "Wrote $OUT with the boot logger. Flash it with: tools/flash-gsi.sh $OUT --keep-data"
