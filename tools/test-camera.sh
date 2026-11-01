#!/usr/bin/env bash
# Collect camera bring-up evidence over ADB.
#
# Usage:
#   tools/test-camera.sh [serial]
#
# If serial is omitted, adb's default device is used (USB or WiFi ADB).
set -u

SERIAL="${1:-}"
ADB=(adb)
if [ -n "$SERIAL" ]; then
    ADB+=(-s "$SERIAL")
fi

OUT="${TMPDIR:-/tmp}/taoshan-camera-test-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

run() {
    local name="$1"
    shift
    {
        echo "\$ $*"
        "$@"
    } >"$OUT/$name.txt" 2>&1
}

echo "Collecting camera state into $OUT"

run ps "${ADB[@]}" shell 'ps -A -Z | grep -iE "mm-qcamera|mediaserver|cameraserver"'
run props "${ADB[@]}" shell 'getprop init.svc.qcamerasvr; getprop init.svc.media; getprop ro.hardware.camera'
run devices "${ADB[@]}" shell 'ls -lZ /dev/video* /dev/msm_camera 2>&1'
run service "${ADB[@]}" shell 'dumpsys media.camera 2>&1 | head -120'

# Trigger the camera app; a manual launch works too.
"${ADB[@]}" shell am start -a android.media.action.IMAGE_CAPTURE >/dev/null 2>&1 || true
sleep 5

run logcat "${ADB[@]}" logcat -d -b all
run dmesg "${ADB[@]}" shell 'dmesg 2>/dev/null'

echo "== process labels =="
cat "$OUT/ps.txt" | grep -iE 'mm-qcamera|mediaserver|cameraserver' || true
echo "== camera service =="
grep -aE 'Number of camera devices|Active Camera Clients|DISCONNECT|ERROR' "$OUT/service.txt" | head -20 || true
echo "== SELinux denials =="
grep -aE 'avc: denied|mm-qcamera|cam_socket|QualcommCamera' "$OUT/logcat.txt" "$OUT/dmesg.txt" | tail -40 || true
echo "Full logs: $OUT"
