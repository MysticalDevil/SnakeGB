#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
# shellcheck source=lib/script_common.sh
# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/lib/script_common.sh"
# shellcheck source=lib/capture_batch.sh
# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/lib/capture_batch.sh"

OUT_DIR="${1:-/tmp/nenoserpent_palette_focus}"
TARGETS="${TARGETS:-menu,game,dbg-replay-buff,dbg-choice}"
PALETTE_STEPS="${PALETTE_STEPS:-0}"
POST_NAV_WAIT="${POST_NAV_WAIT:-1.6}"

mkdir -p "${OUT_DIR}"

script_split_csv_trimmed "${TARGETS}" TARGET_LIST

for target in "${TARGET_LIST[@]}"; do
  out="${OUT_DIR}/nenoserpent_${target}_p${PALETTE_STEPS}.png"
  capture_batch_run_capture "${ROOT_DIR}/scripts/ui/nav/capture.sh" "${target}" "${out}" \
    "${PALETTE_STEPS}" 1 "${POST_NAV_WAIT}"
done

echo "[ok] Captured: ${TARGETS} (palette steps=${PALETTE_STEPS}) -> ${OUT_DIR}"
