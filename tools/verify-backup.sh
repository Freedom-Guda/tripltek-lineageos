#!/usr/bin/env bash
# Verify a tools/backup.sh folder: every GPT partition (except userdata) and both
# preloader copies must exist at exactly the size the tablet reported in
# mtkclient.log. Writes SHA256SUMS only when everything matches.
#
# Usage: tools/verify-backup.sh backups/<device>/<timestamp>
set -euo pipefail

die() { echo "ERROR: $*" >&2; exit 1; }

DIR=${1:?usage: tools/verify-backup.sh BACKUP_DIR}
LOG="$DIR/mtkclient.log"
[ -f "$LOG" ] || die "no mtkclient.log in $DIR"

# "name:   Offset 0x..., Length 0x..., ..." lines printed by mtkclient's printgpt
gpt=$(sed -n 's/^\([A-Za-z0-9_.-]*\): *Offset 0x[0-9a-fA-F]*, Length 0x\([0-9a-fA-F]*\),.*/\1 \2/p' "$LOG" | sort -u)
[ -n "$gpt" ] || die "no partition table found in $LOG (was printgpt run?)"

# emmc_size Boot1|Boot2 - hardware partition size in hex from the DA's EMMC report, or empty.
emmc_size() {
    sed -n "/EMMC $1 Size:/{s/.*: *0x\([0-9a-fA-F]*\).*/\1/p;q}" "$LOG"
}

bad=0
# expect FILE LABEL BYTES
expect() {
    local actual
    if [ ! -f "$1" ]; then
        echo "MISSING $2"; bad=1
    elif actual=$(stat -c %s "$1"); [ "$actual" -ne "$3" ]; then
        echo "WRONG SIZE $2: $actual bytes, expected $3"; bad=1
    else
        echo "ok      $2"
    fi
}

while read -r name hexlen; do
    if [ "$name" = userdata ]; then
        echo "skipped userdata (encrypted, and unlocking wipes it)"
        continue
    fi
    expect "$DIR/partitions/$name.bin" "$name" $((16#$hexlen))
done <<<"$gpt"

for n in 1 2; do
    size=$(emmc_size "Boot$n")
    if [ -n "$size" ]; then
        expect "$DIR/preloader_boot$n.bin" "preloader_boot$n" $((16#$size))
    else
        echo "MISSING eMMC Boot$n size in log, cannot check preloader_boot$n"; bad=1
    fi
done

[ "$bad" -eq 0 ] || die "backup in $DIR is NOT complete"
(cd "$DIR" && find . -type f \( -name '*.bin' -o -name '*.img' \) | sed 's|^\./||' | sort \
    | xargs -d '\n' sha256sum >SHA256SUMS)
echo "Backup verified: every size matches the tablet's partition table."
echo "Checksums written to $DIR/SHA256SUMS"
