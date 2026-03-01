#!/usr/bin/env bash

ui_nav_append_repeated_tokens() {
  local count="$1"
  local token="$2"
  local i=0

  while (( i < count )); do
    UI_NAV_TARGET_STEPS+=("TOKEN:${token}")
    ((i += 1))
  done
}

ui_nav_debug_token() {
  local base_token="$1"
  local injected_params="${2:-}"

  if [[ -n "${injected_params}" ]]; then
    printf '%s:%s' "${base_token}" "${injected_params}"
  else
    printf '%s' "${base_token}"
  fi
}
