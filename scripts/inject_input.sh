#!/usr/bin/env bash
set -euo pipefail

PIPE_PATH="${SNAKEGB_INPUT_PIPE:-/tmp/snakegb-input.pipe}"
if [[ "${1:-}" == "-p" ]]; then
  if [[ $# -lt 2 ]]; then
    echo "[error] Missing value for -p"
    exit 1
  fi
  PIPE_PATH="$2"
  shift 2
fi

if [[ ! -p "${PIPE_PATH}" ]]; then
  echo "[error] Pipe not found: ${PIPE_PATH}"
  echo "Start app with: SNAKEGB_INPUT_PIPE=${PIPE_PATH} ./build-review/SnakeGB"
  exit 1
fi

if [[ "$#" -eq 0 ]]; then
  echo "[info] Interactive mode. Type one token per line (UP/A/START/B/SELECT/F6...), Ctrl-D to exit."
  cat > "${PIPE_PATH}"
  exit 0
fi

for token in "$@"; do
  printf "%s\n" "${token}" > "${PIPE_PATH}"
done
