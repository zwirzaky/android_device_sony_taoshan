#!/usr/bin/env bash
# Runs inside the Ubuntu 16.04 build container (mounted at /src).
set -eo pipefail

export LC_ALL=C
export LANG=C
export USER=builder
export LOGNAME=builder

source build/envsetup.sh
breakfast taoshan

echo "===START_MKA==="
mka bacon -j16
rc=$?
echo "MKA_EXIT=$rc"
exit "$rc"
