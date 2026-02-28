#!/usr/bin/env bash

# shellcheck disable=SC1091
# shellcheck source=lib/script_common.sh
source "${ROOT_DIR}/scripts/lib/script_common.sh"

capture_batch_require_script() {
  local capture_script="$1"

  if [[ ! -x "${capture_script}" ]]; then
    echo "[error] Capture script not executable: ${capture_script}"
    exit 1
  fi
}

capture_batch_validate_palette_step() {
  local palette_step="$1"

  if [[ ! "${palette_step}" =~ ^[0-9]+$ ]]; then
    echo "[error] Invalid palette step: ${palette_step}"
    exit 2
  fi
}

capture_batch_validate_output() {
  local output_png="$1"
  local min_bytes="${2:-4096}"
  local size_bytes=""

  if [[ ! -f "${output_png}" ]]; then
    echo "[error] Missing output screenshot: ${output_png}"
    exit 3
  fi

  size_bytes="$(stat -c%s "${output_png}")"
  if (( size_bytes < min_bytes )); then
    echo "[error] Suspicious screenshot (${size_bytes} bytes): ${output_png}"
    exit 4
  fi
}

capture_batch_run_capture() {
  local capture_script="$1"
  local target="$2"
  local output_png="$3"
  local palette_step="$4"
  local isolated_config="$5"
  local post_nav_wait="$6"
  local palette_token="${7:-${PALETTE_TOKEN:-PALETTE}}"

  echo "[run] palette=${palette_step} target=${target}"
  PALETTE_STEPS="${palette_step}" PALETTE_TOKEN="${palette_token}" \
    POST_NAV_WAIT="${post_nav_wait}" ISOLATED_CONFIG="${isolated_config}" \
    "${capture_script}" "${target}" "${output_png}"

  capture_batch_validate_output "${output_png}"
}
