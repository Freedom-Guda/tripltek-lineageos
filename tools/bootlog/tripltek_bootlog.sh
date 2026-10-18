#!/system/bin/sh
# Debug only: snapshot boot state into /cache/bootlog every 5 s for ~10 min,
# so a boot that hangs before adb can be read back over BROM.
mkdir -p /cache/bootlog
dmesg > /cache/bootlog/dmesg-early.txt 2>&1
i=0
while [ $i -lt 120 ]; do
    echo "$i $(cat /proc/uptime)" > /cache/bootlog/tick.txt
    dmesg > /cache/bootlog/dmesg.txt 2>&1
    logcat -d -b all > /cache/bootlog/logcat.txt 2>&1
    getprop > /cache/bootlog/props.txt 2>&1
    cat /proc/mounts > /cache/bootlog/mounts.txt 2>&1
    ps -A > /cache/bootlog/ps.txt 2>&1
    sync
    i=$((i + 1))
    sleep 5
done
