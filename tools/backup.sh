#!/usr/bin/env bash
# Full stock backup of a Tripltek (MediaTek) tablet over BROM, using mtkclient.
#
# Read-only: reads the raw GPT area, the preloader (eMMC boot1 + boot2) and every
# GPT partition except userdata. Nothing is written to the tablet. The BROM
# exploit lives only in RAM and is gone after the tablet restarts.
#
# Usage: tools/backup.sh [DEVICE_NAME]      (default: T7121)
#   1. Power the tablet off completely (unplugged).
#   2. Run this script. At "Waiting for device", hold BOTH volume buttons and plug USB in.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
MTK_DIR=${MTK_DIR:-$ROOT/third_party/mtkclient}
BACKUP_ROOT=${BACKUP_ROOT:-$ROOT/backups}
DEVICE=${1:-T7121}

die() { echo "ERROR: $*" >&2; exit 1; }

[ -x "$MTK_DIR/.venv/bin/python" ] && [ -f "$MTK_DIR/mtk.py" ] \
    || die "mtkclient not installed at $MTK_DIR (clone it there and run 'uv sync --frozen')"
[[ "$DEVICE" =~ ^[A-Za-z0-9._-]+$ ]] || die "device name may only use letters, digits, . _ -"

if systemctl is-active --quiet ModemManager 2>/dev/null; then
    echo "WARNING: ModemManager is running and can grab the tablet's USB port." >&2
    echo "         If the connection fails: sudo systemctl stop ModemManager" >&2
fi

OUT="$BACKUP_ROOT/$DEVICE/$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$OUT"

# One BROM session; mtkclient splits on ';' and on spaces, so paths must not contain either.
[[ "$OUT" =~ [[:space:]\;] ]] && die "backup path must not contain spaces or ';': $OUT"
cmds="printgpt"
cmds+=";ro 0x0 0x100000 $OUT/emmc_first_1MiB.bin"
cmds+=";r preloader $OUT/preloader_boot1.bin --parttype=boot1"
cmds+=";r preloader $OUT/preloader_boot2.bin --parttype=boot2"
cmds+=";rl $OUT/partitions --skip=userdata"

echo "Backing up $DEVICE into $OUT (read-only)..." >&2
"$MTK_DIR/.venv/bin/python" -I "$MTK_DIR/mtk.py" multi "$cmds" 2>&1 | tee "$OUT/mtkclient.log" \
    || die "mtkclient failed; partial output in $OUT, see mtkclient.log"
grep -q "Failed to dump" "$OUT/mtkclient.log" && die "some partitions failed to dump; see $OUT/mtkclient.log"

"$ROOT/tools/verify-backup.sh" "$OUT"

echo
echo "Backup saved to $OUT"
echo "$(wc -l <"$OUT/SHA256SUMS") images, $(du -sh "$OUT" | cut -f1) total, checksums in SHA256SUMS"
echo "Copy this folder to a second drive before unlocking anything."
