#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CAPTURE_SCRIPT="${CAPTURE_SCRIPT:-${ROOT_DIR}/scripts/ui_nav_capture.sh}"

OUT_DIR="${1:-/tmp/snakegb_palette_matrix}"
TARGETS_CSV="${TARGETS:-menu,achievements,catalog,icons}"
PALETTES_CSV="${PALETTES:-0,1,2,3,4}"
ISOLATED_CONFIG="${ISOLATED_CONFIG:-1}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[error] Missing command: $1"
    exit 1
  fi
}

need_cmd bash
need_cmd sed
need_cmd stat

if [[ ! -x "${CAPTURE_SCRIPT}" ]]; then
  echo "[error] Capture script not executable: ${CAPTURE_SCRIPT}"
  exit 1
fi

mkdir -p "${OUT_DIR}"

IFS=',' read -r -a TARGETS <<<"${TARGETS_CSV}"
IFS=',' read -r -a PALETTES <<<"${PALETTES_CSV}"

echo "[info] Out dir: ${OUT_DIR}"
echo "[info] Targets: ${TARGETS_CSV}"
echo "[info] Palettes: ${PALETTES_CSV}"

for palette in "${PALETTES[@]}"; do
  if [[ ! "${palette}" =~ ^[0-9]+$ ]]; then
    echo "[error] Invalid palette step: ${palette}"
    exit 2
  fi

  for target in "${TARGETS[@]}"; do
    out_png="${OUT_DIR}/palette_${palette}_${target}.png"
    echo "[run] palette=${palette} target=${target}"
    PALETTE_STEPS="${palette}" PALETTE_TOKEN="${PALETTE_TOKEN:-PALETTE}" \
      ISOLATED_CONFIG="${ISOLATED_CONFIG}" "${CAPTURE_SCRIPT}" "${target}" "${out_png}"

    if [[ ! -f "${out_png}" ]]; then
      echo "[error] Missing output screenshot: ${out_png}"
      exit 3
    fi
    size_bytes="$(stat -c%s "${out_png}")"
    if (( size_bytes < 4096 )); then
      echo "[error] Suspiciously small screenshot (${size_bytes} bytes): ${out_png}"
      exit 4
    fi
  done
done

echo "[ok] Capture matrix done."
echo "[ok] Files:"
ls -1 "${OUT_DIR}"/palette_*.png
