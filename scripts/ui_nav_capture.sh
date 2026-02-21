#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-${ROOT_DIR}/build-review}"
APP_BIN="${APP_BIN:-${BUILD_DIR}/SnakeGB}"
WINDOW_CLASS="${WINDOW_CLASS:-devil.org.SnakeGB}"
WINDOW_TITLE="${WINDOW_TITLE:-Snake GB Edition}"
WAIT_SECONDS="${WAIT_SECONDS:-14}"
BOOT_SETTLE_SECONDS="${BOOT_SETTLE_SECONDS:-4.2}"
NAV_STEP_DELAY="${NAV_STEP_DELAY:-0.25}"
POST_NAV_WAIT="${POST_NAV_WAIT:-1.6}"
PALETTE_STEPS="${PALETTE_STEPS:-0}"
TARGET="${1:-menu}"
OUT_PNG="${2:-/tmp/snakegb_ui_nav_${TARGET}.png}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[error] Missing command: $1"
    exit 1
  fi
}

need_cmd cmake
need_cmd hyprctl
need_cmd jq
need_cmd grim

if [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
  echo "[error] This script expects Wayland (current: ${XDG_SESSION_TYPE:-unknown})"
  exit 1
fi

echo "[info] Building ${BUILD_DIR}"
cmake --build "${BUILD_DIR}" --parallel >/dev/null

if [[ ! -x "${APP_BIN}" ]]; then
  echo "[error] App binary not found: ${APP_BIN}"
  exit 1
fi

# Prevent stale windows from previous runs from being matched.
pkill -f "${APP_BIN}" >/dev/null 2>&1 || true
sleep 0.2

echo "[info] Launching ${APP_BIN}"
"${APP_BIN}" >/tmp/snakegb_ui_nav_runtime.log 2>&1 &
APP_PID=$!
cleanup() {
  kill "${APP_PID}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

WINDOW_ADDR=""
GEOM=""
DEADLINE=$((SECONDS + WAIT_SECONDS))
while (( SECONDS < DEADLINE )); do
  WINDOW_INFO="$(hyprctl clients -j | jq -r --arg cls "${WINDOW_CLASS}" --arg ttl "${WINDOW_TITLE}" --argjson pid "${APP_PID}" '
    .[] | select((.pid == $pid) or (.class == $cls) or (.title | contains($ttl))) |
    "\(.address)\t\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"
  ' | head -n1)"

  if [[ -n "${WINDOW_INFO}" ]]; then
    WINDOW_ADDR="${WINDOW_INFO%%$'\t'*}"
    GEOM="${WINDOW_INFO#*$'\t'}"
    break
  fi
  sleep 0.2
done

if [[ -z "${WINDOW_ADDR}" || -z "${GEOM}" ]]; then
  echo "[error] Could not find game window."
  exit 2
fi

# Focus the exact window by address so key injection is deterministic.
hyprctl dispatch focuswindow "address:${WINDOW_ADDR}" >/dev/null || true
sleep "${BOOT_SETTLE_SECONDS}"

send_key() {
  local key="$1"
  # Prefer targeting by address. Fallback to active-window dispatch.
  if ! hyprctl dispatch sendshortcut ",${key},address:${WINDOW_ADDR}" >/dev/null 2>&1; then
    hyprctl dispatch sendshortcut ",${key}," >/dev/null 2>&1 || true
  fi
  sleep "${NAV_STEP_DELAY}"
}

case "${TARGET}" in
  menu)
    ;;
  game)
    send_key "Return"
    ;;
  achievements|medals)
    send_key "Up"
    ;;
  replay)
    send_key "Down"
    ;;
  catalog|library)
    send_key "Left"
    ;;
  *)
    echo "[error] Unknown target '${TARGET}'. Supported: menu|game|achievements|medals|replay|catalog|library"
    exit 3
    ;;
esac

if [[ "${PALETTE_STEPS}" =~ ^[0-9]+$ ]] && (( PALETTE_STEPS > 0 )); then
  i=0
  while (( i < PALETTE_STEPS )); do
    send_key "B"
    ((i += 1))
  done
fi

sleep "${POST_NAV_WAIT}"
mkdir -p "$(dirname "${OUT_PNG}")"
grim -g "${GEOM}" "${OUT_PNG}"
echo "[ok] Target: ${TARGET}"
echo "[ok] Palette steps: ${PALETTE_STEPS}"
echo "[ok] Screenshot saved: ${OUT_PNG}"
echo "[ok] Geometry: ${GEOM}"
