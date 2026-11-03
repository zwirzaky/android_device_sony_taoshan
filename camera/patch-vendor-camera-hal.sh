#!/bin/sh
# Apply the taoshan QCamera releaseHeapMem workaround to the prebuilt HAL.
# The vendor blob is not a git repository, so the 4-byte change lives here.
set -e
ROOT="${ANDROID_BUILD_TOP:-$(pwd)}"
HAL="${1:-$ROOT/vendor/sony/taoshan/proprietary/lib/hw/camera.vendor.msm8960.so}"
[ -f "$HAL" ] || { echo "missing $HAL" >&2; exit 1; }
python3 - "$HAL" <<'PY'
import sys
from pathlib import Path
p = Path(sys.argv[1])
b = bytearray(p.read_bytes())
off = 0x272ae
current = bytes(b[off:off+4])
if current == bytes.fromhex("00bf00bf"):
    print("already patched")
    raise SystemExit(0)
if current != bytes.fromhex("f7f741f9"):
    raise SystemExit("unexpected HAL bytes at 0x272ae: " + current.hex())
b[off:off+4] = bytes.fromhex("00bf00bf")
p.write_bytes(b)
print("patched", p, "at", hex(off))
PY
