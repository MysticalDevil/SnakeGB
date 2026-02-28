#!/usr/bin/env bash

ui_nav_need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[error] Missing command: $1"
    exit 1
  fi
}

ui_nav_require_wayland() {
  if [[ "${XDG_SESSION_TYPE:-}" != "wayland" ]]; then
    echo "[error] This script expects Wayland (current: ${XDG_SESSION_TYPE:-unknown})"
    exit 1
  fi
}

ui_nav_acquire_lock() {
  local lock_file="$1"
  local wait_prefix="$2"

  exec 9>"${lock_file}"
  if ! flock -n 9; then
    echo "[info] ${wait_prefix}; waiting for ${lock_file}"
    flock 9
  fi
}

ui_nav_build_app() {
  local build_dir="$1"
  local app_bin="$2"

  echo "[info] Building ${build_dir}"
  cmake --build "${build_dir}" --parallel >/dev/null

  if [[ ! -x "${app_bin}" ]]; then
    echo "[error] App binary not found: ${app_bin}"
    exit 1
  fi
}

ui_nav_setup_isolated_config() {
  local enabled="$1"

  UI_NAV_CFG_TMP=""
  if [[ "${enabled}" == "1" ]]; then
    UI_NAV_CFG_TMP="$(mktemp -d /tmp/snakegb_ui_cfg.XXXXXX)"
    export XDG_CONFIG_HOME="${UI_NAV_CFG_TMP}"
  fi
}

ui_nav_cleanup_runtime() {
  if [[ -n "${UI_NAV_APP_PID:-}" ]]; then
    kill "${UI_NAV_APP_PID}" >/dev/null 2>&1 || true
  fi
  if [[ -n "${UI_NAV_CFG_TMP:-}" && -d "${UI_NAV_CFG_TMP}" ]]; then
    rm -rf "${UI_NAV_CFG_TMP}"
  fi
}

ui_nav_find_window_for_pid() {
  local pid="$1"
  local wait_seconds="$2"
  local deadline=$((SECONDS + wait_seconds))
  local clients_json=""
  local window_info=""

  # shellcheck disable=SC2034 # Consumed by callers after this shared helper returns.
  UI_NAV_WINDOW_ADDR=""
  # shellcheck disable=SC2034 # Consumed by callers after this shared helper returns.
  UI_NAV_GEOM=""

  while (( SECONDS < deadline )); do
    clients_json="$(hyprctl clients -j 2>&1 || true)"
    if ! jq -e . >/dev/null 2>&1 <<<"${clients_json}"; then
      sleep 0.2
      continue
    fi

    window_info="$(jq -r --argjson pid "${pid}" '
      .[] | select(.pid == $pid) |
      "\(.address)\t\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"
    ' <<<"${clients_json}" | head -n 1)"

    if [[ -n "${window_info}" ]]; then
      UI_NAV_WINDOW_ADDR="${window_info%%$'\t'*}"
      UI_NAV_GEOM="${window_info#*$'\t'}"
      return 0
    fi

    sleep 0.2
  done

  return 1
}

ui_nav_launch_and_locate() {
  local app_bin="$1"
  local input_file="$2"
  local wait_seconds="$3"
  local runtime_log="$4"
  local max_launch_attempts="${5:-1}"
  local attempt=1

  UI_NAV_APP_PID=""
  # shellcheck disable=SC2034 # Consumed by callers after this shared helper returns.
  UI_NAV_WINDOW_ADDR=""
  # shellcheck disable=SC2034 # Consumed by callers after this shared helper returns.
  UI_NAV_GEOM=""

  while (( attempt <= max_launch_attempts )); do
    pkill -f "${app_bin}" >/dev/null 2>&1 || true
    sleep 0.2

    if [[ "${max_launch_attempts}" -gt 1 ]]; then
      echo "[info] Launching ${app_bin} (attempt ${attempt}/${max_launch_attempts})"
    else
      echo "[info] Launching ${app_bin}"
    fi
    rm -f "${input_file}" >/dev/null 2>&1 || true
    SNAKEGB_INPUT_FILE="${input_file}" "${app_bin}" >"${runtime_log}" 2>&1 &
    UI_NAV_APP_PID=$!

    if ui_nav_find_window_for_pid "${UI_NAV_APP_PID}" "${wait_seconds}"; then
      return 0
    fi

    kill "${UI_NAV_APP_PID}" >/dev/null 2>&1 || true
    UI_NAV_APP_PID=""
    attempt=$((attempt + 1))
  done

  return 1
}

ui_nav_send_token() {
  local input_file="$1"
  local nav_step_delay="$2"
  local token="$3"

  printf '%s\n' "${token}" >>"${input_file}"
  sleep "${nav_step_delay}"
}

ui_nav_send_konami() {
  local input_file="$1"
  local nav_step_delay="$2"
  local seq=(U U D D L R L R B A)
  local token=""

  for token in "${seq[@]}"; do
    ui_nav_send_token "${input_file}" "${nav_step_delay}" "${token}"
  done
}

ui_nav_send_token_list() {
  local input_file="$1"
  local nav_step_delay="$2"
  local raw="$3"
  local token=""

  if [[ -z "${raw}" ]]; then
    return
  fi

  IFS=',' read -r -a tokens <<<"${raw}"
  for token in "${tokens[@]}"; do
    token="${token#"${token%%[![:space:]]*}"}"
    token="${token%"${token##*[![:space:]]}"}"
    if [[ -n "${token}" ]]; then
      ui_nav_send_token "${input_file}" "${nav_step_delay}" "${token}"
    fi
  done
}

ui_nav_apply_palette_steps() {
  local input_file="$1"
  local nav_step_delay="$2"
  local palette_token="$3"
  local palette_steps="$4"
  local i=0

  if [[ ! "${palette_steps}" =~ ^[0-9]+$ ]] || (( palette_steps <= 0 )); then
    return
  fi

  while (( i < palette_steps )); do
    ui_nav_send_token "${input_file}" "${nav_step_delay}" "${palette_token}"
    ((i += 1))
  done
}
