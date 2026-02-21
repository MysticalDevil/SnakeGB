#!/usr/bin/env bash
set -euo pipefail

ENDPOINT="${SNAKEGB_INPUT_PIPE:-${SNAKEGB_INPUT_FILE:-/tmp/snakegb-input.pipe}}"
if [[ "${1:-}" == "-p" ]]; then
  if [[ $# -lt 2 ]]; then
    echo "[error] Missing value for -p"
    exit 1
  fi
  ENDPOINT="$2"
  shift 2
fi

if [[ ! -p "${ENDPOINT}" && ! -f "${ENDPOINT}" ]]; then
  echo "[error] Input endpoint not found: ${ENDPOINT}"
  echo "Start app with:"
  echo "  SNAKEGB_INPUT_PIPE=${ENDPOINT} ./build-review/SnakeGB"
  echo "or"
  echo "  SNAKEGB_INPUT_FILE=${ENDPOINT} ./build-review/SnakeGB"
  exit 1
fi

if [[ "$#" -eq 0 ]]; then
  echo "[info] Interactive mode. Type one token per line (UP/A/START/B/SELECT/F6...), Ctrl-D to exit."
  cat >> "${ENDPOINT}"
  exit 0
fi

for token in "$@"; do
  if [[ -p "${ENDPOINT}" ]]; then
    printf "%s\n" "${token}" > "${ENDPOINT}"
  else
    printf "%s\n" "${token}" >> "${ENDPOINT}"
  fi
done
