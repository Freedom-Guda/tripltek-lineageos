#!/usr/bin/env bash
# Replace VNDK libraries in a GSI's flattened VNDK APEX with the stock firmware's copies.
#
# MediaTek vendors are often built against MediaTek-modified VNDK libraries, so their
# HALs fail to link against the GSI's AOSP copies (e.g. the GNSS HAL, which then hangs
# system_server). Only libraries already present in the APEX are replaced: adding new
# ones would also need the linker's VNDK library list updated.
#
# Usage: tools/patch-vndk.sh IN.img OUT.img STOCK_SYSTEM_DIR VNDK_VERSION LIB.so...
#   STOCK_SYSTEM_DIR: the extracted stock system image root (holds system/lib*/vndk-N/)
# Example:
#   tools/patch-vndk.sh lineage.img lineage-gnss.img extracted/T7121/system 28 android.hardware.gnss@1.0.so
set -euo pipefail

DEBUGFS=${DEBUGFS:-/usr/sbin/debugfs}

die() { echo "ERROR: $*" >&2; exit 1; }

[ $# -ge 5 ] || die "usage: tools/patch-vndk.sh IN.img OUT.img STOCK_SYSTEM_DIR VNDK_VERSION LIB.so..."
IN=$1 OUT=$2 STOCK=$3 VER=$4
shift 4
[ -f "$IN" ] || die "no such image: $IN"
[ "$(realpath -m "$IN")" != "$(realpath -m "$OUT")" ] || die "IN and OUT must differ (the original is kept clean)"
[[ "$VER" =~ ^[0-9]+$ ]] || die "VNDK_VERSION must be a number, got '$VER'"
APEX=/system/system_ext/apex/com.android.vndk.v$VER

in_image() { "$DEBUGFS" -R "stat $1" "$IN" 2>/dev/null | grep -q '^Inode:'; }

# Validate everything before copying the (multi-GB) image.
cmds=()
for name in "$@"; do
    found=0
    for arch in lib lib64; do
        src="$STOCK/system/$arch/vndk-$VER/$name"
        dst="$APEX/$arch/$name"
        in_image "$dst" || continue
        [ -f "$src" ] || die "$dst is in the image but stock has no $src"
        cmds+=("rm $dst" "write $src $dst" "sif $dst mode 0100644" "sif $dst uid 0" "sif $dst gid 0"
               "ea_set -f CTX $dst security.selinux")
        found=1
    done
    [ "$found" = 1 ] || die "$name is not in $APEX (only existing VNDK libraries can be replaced)"
done

cp --reflink=auto "$IN" "$OUT"
ctx=$(mktemp)
trap 'rm -f "$ctx"' EXIT
printf 'u:object_r:system_lib_file:s0\0' >"$ctx"   # Android stores labels NUL-terminated
printf '%s\n' "${cmds[@]}" | sed "s|CTX|$ctx|" | "$DEBUGFS" -w -f - "$OUT" >/dev/null 2>&1

for name in "$@"; do
    for arch in lib lib64; do
        src="$STOCK/system/$arch/vndk-$VER/$name"
        "$DEBUGFS" -R "stat $APEX/$arch/$name" "$OUT" 2>/dev/null | grep -q "Size: $(stat -c %s "$src" 2>/dev/null || echo x)\b" \
            && echo "replaced $arch/$name"
    done
done
echo "Wrote $OUT"
