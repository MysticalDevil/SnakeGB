#!/usr/bin/env bash

script_require_cmds() {
  local cmd=""
  for cmd in "$@"; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
      echo "[error] Missing command: ${cmd}"
      exit 1
    fi
  done
}

script_split_csv_trimmed() {
  local raw="$1"
  local output_name="$2"
  local -n output_ref="${output_name}"
  local fields=()
  local field=""

  output_ref=()
  IFS=',' read -r -a fields <<<"${raw}"
  for field in "${fields[@]}"; do
    field="${field#"${field%%[![:space:]]*}"}"
    field="${field%"${field##*[![:space:]]}"}"
    if [[ -n "${field}" ]]; then
      output_ref+=("${field}")
    fi
  done
}
