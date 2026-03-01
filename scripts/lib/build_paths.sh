#!/usr/bin/env bash
set -euo pipefail

BUILD_PATHS_ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

resolve_build_dir() {
  local profile="$1"

  if [[ -n "${BUILD_DIR:-}" ]]; then
    echo "${BUILD_DIR}"
    return 0
  fi

  echo "${BUILD_PATHS_ROOT_DIR}/build/${profile}"
}
