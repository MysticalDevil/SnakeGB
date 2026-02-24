#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CAPTURE_SCRIPT="${CAPTURE_SCRIPT:-${ROOT_DIR}/scripts/ui_nav_capture.sh}"

PALETTE_STEP="${1:-0}"
OUT_DIR="${2:-/tmp/snakegb_palette_single}"
TARGETS_CSV="${3:-${TARGETS:-splash,menu,dbg-static-game,game,replay,dbg-choice,dbg-static-replay,dbg-catalog,dbg-achievements}}"
ISOLATED_CONFIG="${ISOLATED_CONFIG:-1}"
POST_NAV_WAIT="${POST_NAV_WAIT:-1.8}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[error] Missing command: $1"
    exit 1
  fi
}

need_cmd bash
need_cmd stat

if [[ ! -x "${CAPTURE_SCRIPT}" ]]; then
  echo "[error] Capture script not executable: ${CAPTURE_SCRIPT}"
  exit 1
fi

if [[ ! "${PALETTE_STEP}" =~ ^[0-9]+$ ]]; then
  echo "[error] Invalid palette step: ${PALETTE_STEP}"
  exit 2
fi

mkdir -p "${OUT_DIR}"

IFS=',' read -r -a TARGETS <<<"${TARGETS_CSV}"

echo "[info] Out dir: ${OUT_DIR}"
echo "[info] Targets: ${TARGETS_CSV}"
echo "[info] Palette: ${PALETTE_STEP}"

for target in "${TARGETS[@]}"; do
  out_png="${OUT_DIR}/palette_${PALETTE_STEP}_${target}.png"
  echo "[run] palette=${PALETTE_STEP} target=${target}"
  PALETTE_STEPS="${PALETTE_STEP}" POST_NAV_WAIT="${POST_NAV_WAIT}" \
    ISOLATED_CONFIG="${ISOLATED_CONFIG}" "${CAPTURE_SCRIPT}" "${target}" "${out_png}"

  if [[ ! -f "${out_png}" ]]; then
    echo "[error] Missing output screenshot: ${out_png}"
    exit 3
  fi
  size_bytes="$(stat -c%s "${out_png}")"
  if (( size_bytes < 4096 )); then
    echo "[error] Suspicious screenshot (${size_bytes} bytes): ${out_png}"
    exit 4
  fi
done

echo "[ok] Single-palette capture done."
ls -1 "${OUT_DIR}"/palette_"${PALETTE_STEP}"_*.png
