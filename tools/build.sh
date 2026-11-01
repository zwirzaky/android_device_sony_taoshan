#!/usr/bin/env bash
# Build LineageOS 16.0 for taoshan inside the Ubuntu 16.04 container.
set -euo pipefail

TOOLS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$TOOLS/../../../.." && pwd)"

mkdir -p "$SRC/.ccache"
chmod 777 "$SRC/.ccache" 2>/dev/null || true

if ! docker image inspect lineage151-builder >/dev/null 2>&1; then
    docker build -t lineage151-builder -f "$TOOLS/Dockerfile" "$TOOLS"
fi

exec docker run --rm \
    --name lineage151-build \
    --user 1000:1000 \
    -e HOME=/home/builder \
    -e CCACHE_TEMPDIR=/tmp \
    -v "$SRC:/src" \
    -v "$SRC/.ccache:/ccache" \
    -w /src \
    lineage151-builder \
    bash -lc 'ccache -M 30G && bash /src/device/sony/taoshan/tools/inside-build.sh'
