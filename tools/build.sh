#!/usr/bin/env bash
# Build LineageOS 16.0 for taoshan inside the Ubuntu 16.04 container.
set -euo pipefail

TOOLS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$TOOLS/../../../.." && pwd)"

mkdir -p "$SRC/.ccache"
chmod 777 "$SRC/.ccache" 2>/dev/null || true

if ! docker image inspect lineage171-builder >/dev/null 2>&1; then
    docker build -t lineage171-builder -f "$TOOLS/Dockerfile-17.1" "$TOOLS"
fi

BUILD_LOG="${BUILD_LOG:-/tmp/opencode/taoshan17-build.log}"
mkdir -p "$(dirname "$BUILD_LOG")"

set +e
docker run --rm \
    --name lineage171-build \
    --user 1000:1000 \
    -e HOME=/home/builder \
    -e CCACHE_TEMPDIR=/tmp \
    -v "$SRC:/src" \
    -v "$SRC/.ccache:/ccache" \
    -w /src \
    lineage171-builder \
    bash -lc 'ccache -M 30G && bash /src/device/sony/taoshan/tools/inside-build.sh' \
    2>&1 | tee -a "$BUILD_LOG"
rc=${PIPESTATUS[0]}
set -e
exit "$rc"
