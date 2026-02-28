#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/build_paths.sh
source "${ROOT_DIR}/scripts/lib/build_paths.sh"
# shellcheck source=lib/ui_nav_targets.sh
source "${ROOT_DIR}/scripts/lib/ui_nav_targets.sh"

BUILD_DIR="$(resolve_build_dir dev)"
APP_BIN="${APP_BIN:-${BUILD_DIR}/SnakeGB}"
WAIT_SECONDS="${WAIT_SECONDS:-14}"
BOOT_SETTLE_SECONDS="${BOOT_SETTLE_SECONDS:-4.2}"
NAV_STEP_DELAY="${NAV_STEP_DELAY:-0.25}"
NAV_RETRIES="${NAV_RETRIES:-2}"
POST_NAV_WAIT="${POST_NAV_WAIT:-1.6}"
MAX_LAUNCH_ATTEMPTS="${MAX_LAUNCH_ATTEMPTS:-3}"
PALETTE_STEPS="${PALETTE_STEPS:-0}"
PALETTE_TOKEN="${PALETTE_TOKEN:-PALETTE}"
PRE_TOKENS="${PRE_TOKENS:-}"
POST_TOKENS="${POST_TOKENS:-}"
ISOLATED_CONFIG="${ISOLATED_CONFIG:-1}"
INPUT_FILE="${INPUT_FILE:-/tmp/snakegb_ui_input.txt}"
CAPTURE_LOCK_FILE="${CAPTURE_LOCK_FILE:-/tmp/snakegb_ui_nav_capture.lock}"
TARGET="${1:-menu}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[error] Missing command: $1"
    exit 1
  fi
}

usage() {
  cat <<EOF
Usage:
  ./scripts/ui_nav_debug.sh <target>
  ./scripts/ui_nav_debug.sh list

Targets:
  $(ui_nav_supported_targets)

Useful env vars:
  PRE_TOKENS=COLOR
  POST_TOKENS=RIGHT,B
  PALETTE_STEPS=4
  ISOLATED_CONFIG=0
  INPUT_FILE=/tmp/custom_input.txt
EOF
}

if [[ "${TARGET}" == "list" || "${TARGET}" == "--help" || "${TARGET}" == "-h" ]]; then
  usage
  exit 0
fi

need_cmd cmake
need_cmd flock
need_cmd hyprctl
need_cmd jq

if [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
  echo "[error] This script expects Wayland (current: ${XDG_SESSION_TYPE:-unknown})"
  exit 1
fi

exec 9>"${CAPTURE_LOCK_FILE}"
if ! flock -n 9; then
  echo "[info] Another UI navigation session is running; waiting for ${CAPTURE_LOCK_FILE}"
  flock 9
fi

echo "[info] Building ${BUILD_DIR}"
cmake --build "${BUILD_DIR}" --parallel >/dev/null

if [[ ! -x "${APP_BIN}" ]]; then
  echo "[error] App binary not found: ${APP_BIN}"
  exit 1
fi

CFG_TMP=""
if [[ "${ISOLATED_CONFIG}" == "1" ]]; then
  CFG_TMP="$(mktemp -d /tmp/snakegb_ui_cfg.XXXXXX)"
  export XDG_CONFIG_HOME="${CFG_TMP}"
fi

APP_PID=""

cleanup() {
  if [[ -n "${APP_PID}" ]]; then
    kill "${APP_PID}" >/dev/null 2>&1 || true
  fi
  if [[ -n "${CFG_TMP}" && -d "${CFG_TMP}" ]]; then
    rm -rf "${CFG_TMP}"
  fi
}
trap cleanup EXIT

WINDOW_ADDR=""
GEOM=""
attempt=1
while (( attempt <= MAX_LAUNCH_ATTEMPTS )); do
  pkill -f "${APP_BIN}" >/dev/null 2>&1 || true
  sleep 0.2

  echo "[info] Launching ${APP_BIN} (attempt ${attempt}/${MAX_LAUNCH_ATTEMPTS})"
  rm -f "${INPUT_FILE}" >/dev/null 2>&1 || true
  SNAKEGB_INPUT_FILE="${INPUT_FILE}" "${APP_BIN}" >/tmp/snakegb_ui_nav_runtime.log 2>&1 &
  APP_PID=$!

  DEADLINE=$((SECONDS + WAIT_SECONDS))
  while (( SECONDS < DEADLINE )); do
    CLIENTS_JSON="$(hyprctl clients -j 2>&1 || true)"
    if ! jq -e . >/dev/null 2>&1 <<<"${CLIENTS_JSON}"; then
      sleep 0.2
      continue
    fi

    WINDOW_INFO="$(jq -r --argjson pid "${APP_PID}" '
      .[] | select(.pid == $pid) |
      "\(.address)\t\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"
    ' <<<"${CLIENTS_JSON}" | head -n1)"

    if [[ -n "${WINDOW_INFO}" ]]; then
      WINDOW_ADDR="${WINDOW_INFO%%$'\t'*}"
      GEOM="${WINDOW_INFO#*$'\t'}"
      break
    fi
    sleep 0.2
  done

  if [[ -n "${WINDOW_ADDR}" && -n "${GEOM}" ]]; then
    break
  fi

  kill "${APP_PID}" >/dev/null 2>&1 || true
  APP_PID=""
  attempt=$((attempt + 1))
done

if [[ -z "${WINDOW_ADDR}" || -z "${GEOM}" ]]; then
  echo "[error] Could not find game window."
  tail -n 80 /tmp/snakegb_ui_nav_runtime.log || true
  exit 2
fi

sleep "${BOOT_SETTLE_SECONDS}"

send_token() {
  local token="$1"
  printf '%s\n' "${token}" >>"${INPUT_FILE}"
  sleep "${NAV_STEP_DELAY}"
}

send_konami() {
  local seq=(U U D D L R L R B A)
  local k
  for k in "${seq[@]}"; do
    send_token "${k}"
  done
}

send_token_list() {
  local raw="$1"
  local token
  if [[ -z "${raw}" ]]; then
    return
  fi
  IFS=',' read -r -a tokens <<<"${raw}"
  for token in "${tokens[@]}"; do
    token="${token#"${token%%[![:space:]]*}"}"
    token="${token%"${token##*[![:space:]]}"}"
    if [[ -n "${token}" ]]; then
      send_token "${token}"
    fi
  done
}

send_token_list "${PRE_TOKENS}"

if [[ "${PALETTE_STEPS}" =~ ^[0-9]+$ ]] && (( PALETTE_STEPS > 0 )); then
  i=0
  while (( i < PALETTE_STEPS )); do
    send_token "${PALETTE_TOKEN}"
    ((i += 1))
  done
fi

ui_nav_apply_target "${TARGET}"
send_token_list "${POST_TOKENS}"

sleep "${POST_NAV_WAIT}"
if ! kill -0 "${APP_PID}" >/dev/null 2>&1; then
  echo "[error] App exited during setup. Recent log:"
  tail -n 80 /tmp/snakegb_ui_nav_runtime.log || true
  exit 5
fi

cat <<EOF
[ok] Target ready: ${TARGET}
[ok] PID: ${APP_PID}
[ok] Window: ${WINDOW_ADDR}
[ok] Geometry: ${GEOM}
[ok] Input file: ${INPUT_FILE}
[ok] Runtime log: /tmp/snakegb_ui_nav_runtime.log
[hint] Send more tokens with:
       printf 'START\n' >> ${INPUT_FILE}
[hint] Close the app normally, or press Ctrl+C in this terminal.
EOF

wait "${APP_PID}"
