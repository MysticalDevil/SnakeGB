#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${ROOT_DIR}/build-review}"
APP_BIN="${APP_BIN:-${BUILD_DIR}/SnakeGB}"
WINDOW_CLASS="${WINDOW_CLASS:-devil.org.SnakeGB}"
WINDOW_TITLE="${WINDOW_TITLE:-Snake GB Edition}"
WAIT_SECONDS="${WAIT_SECONDS:-14}"
BOOT_SETTLE_SECONDS="${BOOT_SETTLE_SECONDS:-4.2}"
STEP_DELAY="${STEP_DELAY:-0.22}"
POST_CASE_WAIT="${POST_CASE_WAIT:-0.45}"
FAIL_DIR="${FAIL_DIR:-/tmp/snakegb_input_matrix_fail}"
CASE_TIMEOUT="${CASE_TIMEOUT:-120}"

source "${ROOT_DIR}/scripts/lib/input_matrix_common.sh"
source "${ROOT_DIR}/scripts/input_semantics_cases_wayland.sh"

need_cmd cmake
need_cmd hyprctl
need_cmd jq
need_cmd grim
need_cmd ps

if [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
  echo "[error] This script expects Wayland (current: ${XDG_SESSION_TYPE:-unknown})"
  exit 1
fi

trap cleanup_case EXIT

echo "[info] Building ${BUILD_DIR}"
cmake --build "${BUILD_DIR}" --parallel >/dev/null

if [[ ! -x "${APP_BIN}" ]]; then
  echo "[error] App binary not found: ${APP_BIN}"
  exit 1
fi

run_input_semantics_cases

echo "[ok] Input semantics matrix (Wayland) passed"
