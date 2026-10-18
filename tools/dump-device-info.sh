#!/usr/bin/env bash
# Dump useful device info for ROM porting work.
# Usage: ./dump-device-info.sh > my-tripltek-dump.txt
#
# Run from a PC with adb installed and a Tripltek device connected with USB
# debugging enabled. The script writes a single combined report to stdout.
#
# IMPORTANT: review the output for personal info (serial, IMEI, MAC addresses,
# accounts) and redact before posting publicly. See docs/how-to-dump-device-info.md.

set -u

if ! command -v adb >/dev/null 2>&1; then
    echo "ERROR: adb not found in PATH. Install Google's platform-tools first." >&2
    exit 1
fi

devices_line=$(adb devices | sed -n '2p')
if [ -z "${devices_line}" ] || echo "${devices_line}" | grep -q "unauthorized"; then
    echo "ERROR: no authorized device. Run 'adb devices' and accept the prompt on the tablet." >&2
    exit 1
fi

section() {
    echo
    echo "===================================================================="
    echo "== $1"
    echo "===================================================================="
}

run() {
    local label=$1; shift
    section "${label}"
    echo "\$ adb shell $*"
    adb shell "$@" 2>&1 || echo "(command failed)"
}

section "Tripltek device info dump"
echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "Host: $(uname -a 2>/dev/null || echo unknown)"

run "getprop"                getprop
run "uname -a"               uname -a
run "/proc/cpuinfo"          cat /proc/cpuinfo
run "/proc/meminfo"          cat /proc/meminfo
run "/proc/cmdline"          cat /proc/cmdline
run "/proc/partitions"       cat /proc/partitions
run "partitions by name"     ls -la /dev/block/by-name/
run "df -h"                  df -h
run "/vendor/build.prop"     cat /vendor/build.prop
run "/system/build.prop"     cat /system/build.prop
run "kernel version"         cat /proc/version
run "selinux mode"           getenforce

section "End of dump — REVIEW FOR PII BEFORE POSTING"
