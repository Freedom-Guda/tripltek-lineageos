#!/usr/bin/env bash
# Tests tools/backup.sh against a fake mtkclient. Run: tests/backup_test.sh
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
fails=0
CRITICAL="nvram nvdata nvcfg protect1 protect2 proinfo seccfg lk boot recovery system vendor"

# Fake mtkclient checkout: its python logs the multi command list and makes
# one fake image per read so the checksum step has something to hash.
mkdir -p "$WORK/mtk/.venv/bin"
touch "$WORK/mtk/mtk.py"
cat >"$WORK/mtk/.venv/bin/python" <<SHIM
#!/usr/bin/env bash
printf '%s\n' "\$4" >"$WORK/multi.log"
IFS=';' read -ra cmds <<<"\$4"
echo "DAXFlash - EMMC Boot1 Size: 0x4"
echo "DAXFlash - EMMC Boot2 Size: 0x4"
for n in $CRITICAL userdata; do echo "\$n:   Offset 0x0, Length 0x4, Flags 0x0, UUID x, Type EFI_BASIC_DATA"; done
for c in "\${cmds[@]}"; do
    set -- \$c
    case "\$1" in
        ro) echo img >"\$4" ;;
        r) echo img >"\$3" ;;
        rl) mkdir -p "\$2" && for n in \${FAKE_PARTS:-$CRITICAL}; do echo img >"\$2/\$n.bin"; done ;;
    esac
done
SHIM
chmod +x "$WORK/mtk/.venv/bin/python"

check() { # NAME HAYSTACK NEEDLE
    if grep -qF -- "$3" <<<"$2"; then
        echo "ok   $1"
    else
        echo "FAIL $1: expected '$3' in:"; echo "$2" | sed 's/^/     /'
        fails=$((fails + 1))
    fi
}

out=$(MTK_DIR="$WORK/mtk" BACKUP_ROOT="$WORK/backups" "$ROOT/tools/backup.sh" T7121 </dev/null 2>&1) || true
cmds=$(tr ';' '\n' <"$WORK/multi.log" 2>/dev/null || echo "no multi.log")
check "only read commands"        "$(grep -vE '^(printgpt|ro|r|rl)( |$)' <<<"$cmds" || echo none)" "none"
check "reads preloader boot1"     "$cmds" "--parttype=boot1"
check "reads preloader boot2"     "$cmds" "--parttype=boot2"
check "reads raw GPT area"        "$cmds" "ro 0x0 0x100000"
check "skips userdata"            "$cmds" "--skip=userdata"
check "writes checksums"          "$(cat "$WORK"/backups/T7121/*/SHA256SUMS 2>&1)" "partitions/nvram.bin"
check "reports where it saved"    "$out" "$WORK/backups/T7121/"

out=$(FAKE_PARTS="boot system" MTK_DIR="$WORK/mtk" BACKUP_ROOT="$WORK/b2" "$ROOT/tools/backup.sh" T7121 </dev/null 2>&1) && out="unexpected success"
check "fails if nvram not saved"   "$out" "MISSING nvram"

out=$(MTK_DIR="$WORK/missing" "$ROOT/tools/backup.sh" T7121 </dev/null 2>&1) && out="unexpected success"
check "explains missing mtkclient" "$out" "mtkclient not installed"

[ "$fails" -eq 0 ] && echo "all passed" || { echo "$fails failed"; exit 1; }
