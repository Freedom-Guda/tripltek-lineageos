#!/usr/bin/env bash
# Watch what the kernel does to the backlight as the tablet heats up. Needs root (Magisk).
#
# Read-only: lists which thermal zones the backlight cooling devices are bound to, then
# samples the framework brightness, the real kernel backlight level, key temperatures and
# the summed state of the backlight coolers. If the kernel level drops while the framework
# value stays put and the cooler state rises, the kernel is thermally dimming the screen.
#
# Usage: tools/thermal-watch.sh [DURATION_S=900] [INTERVAL_S=10]
# Output: dumps/<DEVICE>/thermal-<UTC timestamp>.csv (DEVICE defaults to T7121)
set -euo pipefail

ADB=${ADB:-adb}
OUT_ROOT=${OUT_ROOT:-dumps}
DEVICE=${DEVICE:-T7121}
DURATION=${1:-900}
INTERVAL=${2:-10}

die() { echo "ERROR: $*" >&2; exit 1; }

# root_sh 'device script' - run as root; the script must not contain single quotes.
root_sh() { "$ADB" shell "su -c '$1'" </dev/null | tr -d '\r'; }

BINDINGS=$(cat <<'EOF'
for z in /sys/class/thermal/thermal_zone*; do for l in $z/cdev[0-9]*; do [ -L $l ] || continue; t=$(cat $l/type); case $t in *backlight*) echo "$(cat $z/type) -> $t (trip $(cat ${l}_trip_point))";; esac; done; done
EOF
)

# Prints: kernel_backlight,ap_mC,cpu_mC,battery_mC,backlight_cooler_sum
SAMPLE=$(cat <<'EOF'
s=$(cat /sys/class/leds/lcd-backlight/brightness); for want in mtktsAP mtktscpu mtktsbattery; do v=NA; for z in /sys/class/thermal/thermal_zone*; do [ "$(cat $z/type)" = $want ] && v=$(cat $z/temp); done; s="$s,$v"; done; bl=0; for d in /sys/class/thermal/cooling_device*; do case $(cat $d/type) in *backlight*) bl=$((bl + $(cat $d/cur_state)));; esac; done; echo "$s,$bl"
EOF
)

[ "$(root_sh 'id -u')" = 0 ] || die "no root on the tablet: install Magisk and allow Shell root access"

CSV="$OUT_ROOT/$DEVICE/thermal-$(date -u +%Y%m%dT%H%M%SZ).csv"
mkdir -p "$(dirname "$CSV")"

echo "Backlight cooler bindings (empty = the backlight cooler is not wired to any zone):"
root_sh "$BINDINGS" | sed 's/^/  /'
echo

echo "time_s,framework_brightness,kernel_backlight,ap_mC,cpu_mC,battery_mC,backlight_cooler_sum" | tee "$CSV"
start=$SECONDS
while :; do
    framework=$("$ADB" shell 'settings get system screen_brightness' </dev/null | tr -d '\r')
    echo "$((SECONDS - start)),$framework,$(root_sh "$SAMPLE")" | tee -a "$CSV"
    [ $((SECONDS - start + INTERVAL)) -le "$DURATION" ] || break
    sleep "$INTERVAL"
done
echo "Saved $CSV"
