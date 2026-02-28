#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

OUT_DIR="${1:-/tmp/snakegb_palette_focus}"
TARGETS="${TARGETS:-menu,game,dbg-replay-buff,dbg-choice}"
PALETTE_STEPS="${PALETTE_STEPS:-0}"
POST_NAV_WAIT="${POST_NAV_WAIT:-1.6}"

mkdir -p "${OUT_DIR}"

IFS=',' read -r -a TARGET_LIST <<<"${TARGETS}"

for target in "${TARGET_LIST[@]}"; do
  out="${OUT_DIR}/snakegb_${target}_p${PALETTE_STEPS}.png"
  ISOLATED_CONFIG=1 POST_NAV_WAIT="${POST_NAV_WAIT}" PALETTE_STEPS="${PALETTE_STEPS}" \
    "${ROOT_DIR}/scripts/ui_nav_capture.sh" "${target}" "${out}"
done

echo "[ok] Captured: ${TARGETS} (palette steps=${PALETTE_STEPS}) -> ${OUT_DIR}"
