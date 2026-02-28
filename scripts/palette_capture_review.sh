#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FOCUS_SCRIPT="${FOCUS_SCRIPT:-${ROOT_DIR}/scripts/palette_capture_focus.sh}"
MATRIX_SCRIPT="${MATRIX_SCRIPT:-${ROOT_DIR}/scripts/palette_capture_matrix.sh}"

OUT_DIR="${1:-/tmp/snakegb_palette_review}"
FOCUS_TARGETS="${FOCUS_TARGETS:-menu,game,dbg-replay-buff,dbg-choice}"
MATRIX_TARGETS="${MATRIX_TARGETS:-menu,achievements,catalog,icons}"
PALETTES="${PALETTES:-0,1,2,3,4}"
POST_NAV_WAIT="${POST_NAV_WAIT:-1.8}"
MONTAGE_FONT="${MONTAGE_FONT:-$(fc-match -f '%{file}\n' 'DejaVu Sans' | head -n 1)}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[error] Missing command: $1"
    exit 1
  fi
}

need_cmd bash
need_cmd fc-match
need_cmd montage
need_cmd identify

mkdir -p "${OUT_DIR}/focus" "${OUT_DIR}/matrix" "${OUT_DIR}/sheets"

IFS=',' read -r -a PALETTE_LIST <<<"${PALETTES}"
IFS=',' read -r -a FOCUS_LIST <<<"${FOCUS_TARGETS}"
IFS=',' read -r -a MATRIX_LIST <<<"${MATRIX_TARGETS}"

for palette in "${PALETTE_LIST[@]}"; do
  echo "[round] focus palette=${palette}"
  PALETTE_STEPS="${palette}" TARGETS="${FOCUS_TARGETS}" POST_NAV_WAIT="${POST_NAV_WAIT}" \
    "${FOCUS_SCRIPT}" "${OUT_DIR}/focus"

  focus_inputs=()
  for target in "${FOCUS_LIST[@]}"; do
    focus_inputs+=("${OUT_DIR}/focus/snakegb_${target}_p${palette}.png")
  done
  montage -font "${MONTAGE_FONT}" "${focus_inputs[@]}" -tile 2x -geometry +8+8 "${OUT_DIR}/sheets/focus_p${palette}.png"
done

TARGETS="${MATRIX_TARGETS}" PALETTES="${PALETTES}" POST_NAV_WAIT="${POST_NAV_WAIT}" \
  "${MATRIX_SCRIPT}" "${OUT_DIR}/matrix"

for target in "${MATRIX_LIST[@]}"; do
  matrix_inputs=()
  for palette in "${PALETTE_LIST[@]}"; do
    matrix_inputs+=("${OUT_DIR}/matrix/palette_${palette}_${target}.png")
  done
  montage -font "${MONTAGE_FONT}" "${matrix_inputs[@]}" -tile 5x -geometry +8+8 "${OUT_DIR}/sheets/matrix_${target}.png"
done

echo "[ok] Review capture complete: ${OUT_DIR}"
for sheet in "${OUT_DIR}"/sheets/*.png; do
  dims="$(identify -format '%wx%h' "${sheet}")"
  echo "[ok] $(basename "${sheet}") ${dims}"
done
