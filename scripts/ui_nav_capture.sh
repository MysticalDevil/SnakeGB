#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/build_paths.sh
source "${ROOT_DIR}/scripts/lib/build_paths.sh"
BUILD_DIR="$(resolve_build_dir dev)"
APP_BIN="${APP_BIN:-${BUILD_DIR}/SnakeGB}"
WINDOW_CLASS="${WINDOW_CLASS:-devil.org.SnakeGB}"
WINDOW_TITLE="${WINDOW_TITLE:-Snake GB Edition}"
WAIT_SECONDS="${WAIT_SECONDS:-14}"
BOOT_SETTLE_SECONDS="${BOOT_SETTLE_SECONDS:-4.2}"
NAV_STEP_DELAY="${NAV_STEP_DELAY:-0.25}"
NAV_RETRIES="${NAV_RETRIES:-2}"
POST_NAV_WAIT="${POST_NAV_WAIT:-1.6}"
PALETTE_STEPS="${PALETTE_STEPS:-0}"
PALETTE_TOKEN="${PALETTE_TOKEN:-PALETTE}"
ISOLATED_CONFIG="${ISOLATED_CONFIG:-1}"
INPUT_FILE="${INPUT_FILE:-/tmp/snakegb_ui_input.txt}"
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

# Use an isolated settings dir by default so palette/save persistence does not
# pollute automated captures or make palette steps non-deterministic.
CFG_TMP=""
if [[ "${ISOLATED_CONFIG}" == "1" ]]; then
  CFG_TMP="$(mktemp -d /tmp/snakegb_ui_cfg.XXXXXX)"
  export XDG_CONFIG_HOME="${CFG_TMP}"
fi

# Prevent stale windows from previous runs from being matched.
pkill -f "${APP_BIN}" >/dev/null 2>&1 || true
sleep 0.2

echo "[info] Launching ${APP_BIN}"
rm -f "${INPUT_FILE}" >/dev/null 2>&1 || true
SNAKEGB_INPUT_FILE="${INPUT_FILE}" "${APP_BIN}" >/tmp/snakegb_ui_nav_runtime.log 2>&1 &
APP_PID=$!
cleanup() {
  kill "${APP_PID}" >/dev/null 2>&1 || true
  if [[ -n "${CFG_TMP}" && -d "${CFG_TMP}" ]]; then
    rm -rf "${CFG_TMP}"
  fi
}
trap cleanup EXIT

WINDOW_ADDR=""
GEOM=""
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

if [[ -z "${WINDOW_ADDR}" || -z "${GEOM}" ]]; then
  echo "[error] Could not find game window."
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

if [[ "${PALETTE_STEPS}" =~ ^[0-9]+$ ]] && (( PALETTE_STEPS > 0 )); then
  i=0
  while (( i < PALETTE_STEPS )); do
    send_token "${PALETTE_TOKEN}"
    ((i += 1))
  done
fi

case "${TARGET}" in
  splash)
    # Capture splash shortly after launch before transition to start menu.
    sleep "${SPLASH_CAPTURE_DELAY:-0.02}"
    POST_NAV_WAIT="${SPLASH_POST_WAIT:-0.02}"
    ;;
  menu)
    ;;
  game)
    send_token "START"
    ;;
  pause)
    send_token "START"
    sleep 0.25
    send_token "START"
    ;;
  pause-back)
    send_token "START"
    sleep 0.25
    send_token "START"
    sleep 0.25
    send_token "SELECT"
    ;;
  pause-back-b)
    send_token "START"
    sleep 0.25
    send_token "START"
    sleep 0.25
    send_token "B"
    ;;
  pause-resume)
    send_token "START"
    sleep 0.25
    send_token "START"
    sleep 0.25
    send_token "START"
    ;;
  achievements|medals)
    i=0
    while (( i < NAV_RETRIES )); do
      send_token "UP"
      ((i += 1))
    done
    ;;
  replay)
    i=0
    while (( i < NAV_RETRIES )); do
      send_token "DOWN"
      ((i += 1))
    done
    ;;
  catalog|library)
    i=0
    while (( i < NAV_RETRIES )); do
      send_token "LEFT"
      ((i += 1))
    done
    ;;
  icons)
    send_token "DBG_ICONS"
    ;;
  icons-f6)
    send_token "F6"
    ;;
  icons-right)
    send_token "DBG_ICONS"
    sleep 0.3
    send_token "RIGHT"
    ;;
  konami-on)
    send_konami
    ;;
  konami-off)
    send_konami
    sleep 0.4
    send_konami
    ;;
  konami-on-paused)
    send_token "START"
    sleep 0.25
    send_token "START"
    sleep 0.25
    send_konami
    ;;
  konami-off-paused)
    send_token "START"
    sleep 0.25
    send_token "START"
    sleep 0.25
    send_konami
    sleep 0.4
    send_konami
    ;;
  icons-exit-b)
    send_token "DBG_ICONS"
    sleep 0.3
    send_token "B"
    ;;
  dbg-menu)
    send_token "DBG_MENU"
    ;;
  dbg-play)
    send_token "DBG_PLAY"
    ;;
  dbg-pause)
    send_token "DBG_PAUSE"
    ;;
  dbg-gameover)
    send_token "DBG_GAMEOVER"
    ;;
  dbg-replay)
    send_token "DBG_REPLAY"
    ;;
  dbg-choice)
    send_token "DBG_CHOICE"
    ;;
  dbg-catalog)
    send_token "DBG_CATALOG"
    ;;
  dbg-achievements)
    send_token "DBG_ACHIEVEMENTS"
    ;;
  dbg-icons)
    send_token "DBG_ICONS"
    ;;
  dbg-static-boot)
    send_token "DBG_STATIC_BOOT"
    ;;
  dbg-static-game)
    send_token "DBG_STATIC_GAME"
    ;;
  dbg-static-replay)
    send_token "DBG_STATIC_REPLAY"
    ;;
  dbg-static-off)
    send_token "DBG_STATIC_OFF"
    ;;
  *)
    echo "[error] Unknown target '${TARGET}'. Supported: splash|menu|game|pause|pause-back|pause-back-b|pause-resume|achievements|medals|replay|catalog|library|icons|icons-f6|icons-right|konami-on|konami-off|konami-on-paused|konami-off-paused|icons-exit-b|dbg-menu|dbg-play|dbg-pause|dbg-gameover|dbg-replay|dbg-choice|dbg-catalog|dbg-achievements|dbg-icons|dbg-static-boot|dbg-static-game|dbg-static-replay|dbg-static-off"
    exit 3
    ;;
esac

sleep "${POST_NAV_WAIT}"
if ! kill -0 "${APP_PID}" >/dev/null 2>&1; then
  echo "[error] App exited before screenshot. Recent log:"
  tail -n 80 /tmp/snakegb_ui_nav_runtime.log || true
  exit 5
fi
mkdir -p "$(dirname "${OUT_PNG}")"
grim -g "${GEOM}" "${OUT_PNG}"
echo "[ok] Target: ${TARGET}"
echo "[ok] Palette steps: ${PALETTE_STEPS}"
echo "[ok] Screenshot saved: ${OUT_PNG}"
echo "[ok] Geometry: ${GEOM}"
