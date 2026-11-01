#!/usr/bin/env bash
# Fetch Git LFS objects for the prebuilt Chromium WebView APKs.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
for d in "$ROOT"/external/chromium-webview/prebuilt/*; do
    echo "== $d"
    git -C "$d" lfs install --local
    git -C "$d" lfs pull
done
