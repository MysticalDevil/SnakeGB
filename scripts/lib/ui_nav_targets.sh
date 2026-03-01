#!/usr/bin/env bash

# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/lib/ui_nav_targets/common.sh"
# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/lib/ui_nav_targets/nav.sh"
# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/lib/ui_nav_targets/debug.sh"
# shellcheck disable=SC1091
source "${ROOT_DIR}/scripts/lib/ui_nav_targets/static.sh"

ui_nav_supported_targets() {
  printf '%s\n' \
    "$(ui_nav_nav_supported_targets)|$(ui_nav_debug_supported_targets)|$(ui_nav_static_supported_targets)"
}

ui_nav_build_target_plan() {
  local target="$1"
  local nav_retries="${2:-2}"

  # shellcheck disable=SC2034 # Consumed by caller after this helper returns.
  UI_NAV_TARGET_STEPS=()
  # shellcheck disable=SC2034 # Consumed by caller after this helper returns.
  UI_NAV_TARGET_POST_WAIT_OVERRIDE=""
  # shellcheck disable=SC2034 # Consumed by caller after this helper returns.
  UI_NAV_TARGET_APP_ARGS=""

  if ui_nav_build_nav_target_plan "${target}" "${nav_retries}"; then
    return 0
  fi

  if ui_nav_build_debug_target_plan "${target}"; then
    return 0
  fi

  if ui_nav_build_static_target_plan "${target}"; then
    return 0
  fi

  echo "[error] Unknown target '${target}'. Supported: $(ui_nav_supported_targets)"
  return 3
}
