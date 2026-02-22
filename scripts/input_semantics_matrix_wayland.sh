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

APP_PID=""
WINDOW_ADDR=""
GEOM=""
CFG_TMP=""

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
need_cmd ps

if [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
  echo "[error] This script expects Wayland (current: ${XDG_SESSION_TYPE:-unknown})"
  exit 1
fi

app_is_alive() {
  local stat
  if [[ -z "${APP_PID}" ]]; then
    return 1
  fi
  if ! kill -0 "${APP_PID}" 2>/dev/null; then
    return 1
  fi
  stat="$(ps -p "${APP_PID}" -o stat= 2>/dev/null | tr -d '[:space:]')"
  [[ -n "${stat}" && "${stat#Z}" == "${stat}" ]]
}

stop_app() {
  if app_is_alive; then
    kill "${APP_PID}" >/dev/null 2>&1 || true
    wait "${APP_PID}" >/dev/null 2>&1 || true
  fi
  APP_PID=""
}

cleanup_case() {
  stop_app
  if [[ -n "${CFG_TMP}" && -d "${CFG_TMP}" ]]; then
    rm -rf "${CFG_TMP}"
  fi
  CFG_TMP=""
}

capture_failure() {
  local case_name="$1"
  mkdir -p "${FAIL_DIR}"
  if [[ -n "${GEOM}" ]]; then
    grim -g "${GEOM}" "${FAIL_DIR}/${case_name}.png" >/dev/null 2>&1 || true
  fi
  if [[ -f /tmp/snakegb_input_matrix_runtime.log ]]; then
    cp /tmp/snakegb_input_matrix_runtime.log "${FAIL_DIR}/${case_name}.log" >/dev/null 2>&1 || true
  fi
}

die_case() {
  local case_name="$1"
  local msg="$2"
  echo "[error] ${case_name}: ${msg}"
  capture_failure "${case_name}"
  cleanup_case
  exit 2
}

wait_window_ready() {
  local deadline shell_clients window_info
  deadline=$((SECONDS + WAIT_SECONDS))
  while (( SECONDS < deadline )); do
    shell_clients="$(hyprctl clients -j 2>&1 || true)"
    if ! jq -e . >/dev/null 2>&1 <<<"${shell_clients}"; then
      sleep 0.2
      continue
    fi
    window_info="$(jq -r --arg cls "${WINDOW_CLASS}" --arg ttl "${WINDOW_TITLE}" --argjson pid "${APP_PID}" '
      .[] | select((.pid == $pid) or (.class == $cls) or ((.title // "") | contains($ttl))) |
      "\(.address)\t\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"
    ' <<<"${shell_clients}" | head -n1)"
    if [[ -n "${window_info}" ]]; then
      WINDOW_ADDR="${window_info%%$'\t'*}"
      GEOM="${window_info#*$'\t'}"
      return 0
    fi
    sleep 0.2
  done
  return 1
}

launch_app() {
  CFG_TMP="$(mktemp -d /tmp/snakegb_input_matrix_cfg.XXXXXX)"
  export XDG_CONFIG_HOME="${CFG_TMP}"

  pkill -f "${APP_BIN}" >/dev/null 2>&1 || true
  sleep 0.2

  "${APP_BIN}" >/tmp/snakegb_input_matrix_runtime.log 2>&1 &
  APP_PID=$!

  if ! wait_window_ready; then
    return 1
  fi

  hyprctl dispatch focuswindow "address:${WINDOW_ADDR}" >/dev/null || true
  sleep "${BOOT_SETTLE_SECONDS}"
  return 0
}

send_key() {
  local key="$1"
  if ! hyprctl dispatch sendshortcut ",${key},address:${WINDOW_ADDR}" >/dev/null 2>&1; then
    hyprctl dispatch sendshortcut ",${key}," >/dev/null 2>&1 || true
  fi
  sleep "${STEP_DELAY}"
}

send_konami() {
  local seq=(Up Up Down Down Left Right Left Right X Z)
  local k
  for k in "${seq[@]}"; do
    send_key "${k}"
  done
}

expect_alive() {
  local case_name="$1"
  if ! app_is_alive; then
    die_case "${case_name}" "app exited unexpectedly"
  fi
}

expect_exit() {
  local case_name="$1"
  local i
  for i in $(seq 1 80); do
    if ! app_is_alive; then
      wait "${APP_PID}" >/dev/null 2>&1 || true
      APP_PID=""
      return 0
    fi
    sleep 0.1
  done
  die_case "${case_name}" "app did not exit in time"
}

run_case() {
  local case_name="$1"
  shift
  echo "[case] ${case_name}"
  if ! launch_app; then
    die_case "${case_name}" "failed to launch app window"
  fi
  "$@"
  sleep "${POST_CASE_WAIT}"
  cleanup_case
}

case_menu_b_non_exit() {
  send_key "X"
  expect_alive "case_menu_b_non_exit"
  send_key "Escape"
  expect_exit "case_menu_b_non_exit/cleanup"
}

case_menu_escape_exits() {
  send_key "Escape"
  expect_exit "case_menu_escape_exits"
}

case_menu_select_non_exit() {
  send_key "Shift_L"
  expect_alive "case_menu_select_non_exit"
  send_key "Escape"
  expect_exit "case_menu_select_non_exit/cleanup"
}

case_play_pause_b_non_exit_then_select_menu_then_exit() {
  send_key "Return"   # start game
  send_key "Return"   # pause
  send_key "X"        # B -> palette only
  expect_alive "case_play_pause_b_non_exit_then_select_menu_then_exit"
  send_key "Shift_L"  # SELECT -> back to menu
  expect_alive "case_play_pause_b_non_exit_then_select_menu_then_exit"
  send_key "Escape"   # quit app from menu
  expect_exit "case_play_pause_b_non_exit_then_select_menu_then_exit/cleanup"
}

case_icon_lab_f6_b_exit_no_crash() {
  send_key "F6"       # enter icon lab (deterministic)
  send_key "X"        # B -> back to menu
  expect_alive "case_icon_lab_f6_b_exit_no_crash"
  send_key "Escape"   # quit
  expect_exit "case_icon_lab_f6_b_exit_no_crash/cleanup"
}

case_konami_sequence_no_crash() {
  send_key "Return"   # start game
  send_key "Return"   # pause (Konami input scope)
  send_konami
  expect_alive "case_konami_sequence_no_crash"
  send_key "Escape"   # icon lab -> menu
  expect_alive "case_konami_sequence_no_crash"
  send_key "Escape"   # menu -> quit
  expect_exit "case_konami_sequence_no_crash/cleanup"
}

trap cleanup_case EXIT

echo "[info] Building ${BUILD_DIR}"
cmake --build "${BUILD_DIR}" --parallel >/dev/null

if [[ ! -x "${APP_BIN}" ]]; then
  echo "[error] App binary not found: ${APP_BIN}"
  exit 1
fi

run_case "menu_b_non_exit" case_menu_b_non_exit
run_case "menu_escape_exits" case_menu_escape_exits
run_case "menu_select_non_exit" case_menu_select_non_exit
run_case "play_pause_b_non_exit_then_select_menu_then_exit" case_play_pause_b_non_exit_then_select_menu_then_exit
run_case "icon_lab_f6_b_exit_no_crash" case_icon_lab_f6_b_exit_no_crash
run_case "konami_sequence_no_crash" case_konami_sequence_no_crash

echo "[ok] Input semantics matrix (Wayland) passed"
