#!/usr/bin/env bash
# Extract /bootlog from a cache partition image read over BROM.
#
# Usage: tools/read-bootlog.sh cache.bin OUT_DIR
set -euo pipefail

DEBUGFS=${DEBUGFS:-/usr/sbin/debugfs}

die() { echo "ERROR: $*" >&2; exit 1; }

CACHE=${1:?usage: tools/read-bootlog.sh cache.bin OUT_DIR}
OUT=${2:?usage: tools/read-bootlog.sh cache.bin OUT_DIR}
[ -f "$CACHE" ] || die "no such file: $CACHE"

files=$("$DEBUGFS" -R "ls -p /bootlog" "$CACHE" 2>/dev/null | awk -F/ '$6 ~ /\.txt$/ {print $6}')
[ -n "$files" ] || die "no /bootlog in $CACHE (did the debug image run long enough?)"
mkdir -p "$OUT"
for f in $files; do
    "$DEBUGFS" -R "dump /bootlog/$f $OUT/$f" "$CACHE" 2>/dev/null
done
echo "Extracted to $OUT: $(echo $files)"
