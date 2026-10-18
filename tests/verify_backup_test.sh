#!/usr/bin/env bash
# Tests tools/verify-backup.sh against a fake backup folder. Run: tests/verify_backup_test.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
fails=0

check() { # NAME HAYSTACK NEEDLE
    if grep -qF -- "$3" <<<"$2"; then
        echo "ok   $1"
    else
        echo "FAIL $1: expected '$3' in:"; echo "$2" | sed 's/^/     /'
        fails=$((fails + 1))
    fi
}

# make_backup DIR - backup folder whose files match the fixture GPT exactly.
make_backup() {
    mkdir -p "$1/partitions"
    cp "$ROOT/tests/fixtures/mtkclient_gpt.txt" "$1/mtkclient.log"
    truncate -s $((16#4000)) "$1/partitions/nvram.bin"
    truncate -s $((16#8000)) "$1/partitions/system.bin"
    truncate -s $((16#2000)) "$1/partitions/cache.bin"
    truncate -s $((16#400000)) "$1/preloader_boot1.bin" "$1/preloader_boot2.bin"
}

verify() { "$ROOT/tools/verify-backup.sh" "$1" 2>&1; }

make_backup "$WORK/good"
if out=$(verify "$WORK/good"); then status=0; else status=1; fi
check "complete backup passes"      "exit $status" "exit 0"
check "userdata is not required"    "$out" "skipped userdata"
check "writes checksums on success" "$(cat "$WORK/good/SHA256SUMS" 2>&1)" "partitions/system.bin"

make_backup "$WORK/short"
truncate -s $((16#2000)) "$WORK/short/partitions/system.bin"
if out=$(verify "$WORK/short"); then out="unexpected success"; fi
check "catches truncated partition" "$out" "WRONG SIZE system"
check "no checksums when bad"       "$([ -e "$WORK/short/SHA256SUMS" ] && echo present || echo absent)" "absent"

make_backup "$WORK/missing"
rm "$WORK/missing/partitions/cache.bin"
if out=$(verify "$WORK/missing"); then out="unexpected success"; fi
check "catches missing partition"   "$out" "MISSING cache"

make_backup "$WORK/preloader"
truncate -s 0 "$WORK/preloader/preloader_boot2.bin"
if out=$(verify "$WORK/preloader"); then out="unexpected success"; fi
check "checks preloader size"       "$out" "WRONG SIZE preloader_boot2"

make_backup "$WORK/nogpt"
: >"$WORK/nogpt/mtkclient.log"
if out=$(verify "$WORK/nogpt"); then out="unexpected success"; fi
check "needs a partition table"     "$out" "no partition table"

[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
