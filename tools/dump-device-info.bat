@echo off
REM Dump useful device info for ROM porting work.
REM Usage: dump-device-info.bat > my-tripltek-dump.txt
REM
REM Run from a PC with adb installed and a Tripltek device connected with USB
REM debugging enabled. The script writes a single combined report to stdout.
REM
REM IMPORTANT: review the output for personal info (serial, IMEI, MAC addresses,
REM accounts) and redact before posting publicly.
REM See docs/how-to-dump-device-info.md.

setlocal

where adb >nul 2>&1
if errorlevel 1 (
    echo ERROR: adb not found in PATH. Install Google platform-tools first. 1>&2
    exit /b 1
)

echo ====================================================================
echo == Tripltek device info dump
echo ====================================================================
echo Generated: %date% %time%

call :section "getprop"             & adb shell getprop
call :section "uname -a"            & adb shell uname -a
call :section "/proc/cpuinfo"       & adb shell cat /proc/cpuinfo
call :section "/proc/meminfo"       & adb shell cat /proc/meminfo
call :section "/proc/cmdline"       & adb shell cat /proc/cmdline
call :section "/proc/partitions"    & adb shell cat /proc/partitions
call :section "partitions by name"  & adb shell ls -la /dev/block/by-name/
call :section "df -h"               & adb shell df -h
call :section "/vendor/build.prop"  & adb shell cat /vendor/build.prop
call :section "/system/build.prop"  & adb shell cat /system/build.prop
call :section "kernel version"      & adb shell cat /proc/version
call :section "selinux mode"        & adb shell getenforce

echo.
echo ====================================================================
echo == End of dump -- REVIEW FOR PII BEFORE POSTING
echo ====================================================================
goto :eof

:section
echo.
echo ====================================================================
echo == %~1
echo ====================================================================
goto :eof
