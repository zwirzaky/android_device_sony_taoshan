#!/usr/bin/env bash
# Apply the local compatibility patches after `repo sync`.
set -euo pipefail

TOOLS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$(cd "$TOOLS/../../../.." && pwd)"

apply_patch() {
    local repo="$1"
    local patch="$2"
    if [ ! -d "$SRC/$repo/.git" ]; then
        echo "missing repo: $repo (skipped)"
        return 0
    fi
    if git -C "$SRC/$repo" apply --reverse --check "$patch" 2>/dev/null; then
        echo "already applied: $repo $(basename "$patch")"
    else
        git -C "$SRC/$repo" apply "$patch"
        echo "applied: $repo $(basename "$patch")"
    fi
}

apply_patch device/qcom/common "$TOOLS/patches/0001-qcom-common-power-android9.patch"
apply_patch bionic "$TOOLS/patches/0002-bionic-legacy-text-relocations.patch"
apply_patch hardware/ril-caf "$TOOLS/patches/0003-ril-caf-rild-mmap.patch"
