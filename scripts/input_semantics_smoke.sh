#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/build_paths.sh
source "${ROOT_DIR}/scripts/lib/build_paths.sh"
BUILD_DIR="$(resolve_build_dir dev)"
APP_BIN="${APP_BIN:-${BUILD_DIR}/SnakeGB}"
INPUT_FILE="${INPUT_FILE:-/tmp/snakegb-input.queue}"
LOG_FILE="${LOG_FILE:-/tmp/snakegb_input_semantics_smoke.log}"
RUN_QPA="${RUN_QPA:-offscreen}"

echo "[info] Building ${BUILD_DIR}"
cmake --build "${BUILD_DIR}" --parallel >/dev/null

if [[ ! -x "${APP_BIN}" ]]; then
  echo "[error] App binary not found: ${APP_BIN}"
  exit 1
fi

rm -f "${INPUT_FILE}"

echo "[info] Launching app with input file: ${INPUT_FILE} (QPA=${RUN_QPA})"
QT_QPA_PLATFORM="${RUN_QPA}" \
SNAKEGB_KEEP_STDERR=1 \
SNAKEGB_INPUT_FILE="${INPUT_FILE}" \
"${APP_BIN}" >"${LOG_FILE}" 2>&1 &
APP_PID=$!

cleanup() {
  kill "${APP_PID}" >/dev/null 2>&1 || true
  rm -f "${INPUT_FILE}"
}
trap cleanup EXIT

sleep 1.5
if [[ ! -f "${INPUT_FILE}" ]]; then
  echo "[error] Input file was not created: ${INPUT_FILE}"
  tail -n 80 "${LOG_FILE}" || true
  exit 2
fi

echo "[info] Injecting non-exit action sequence"
./scripts/inject_input.sh -p "${INPUT_FILE}" \
  UP RIGHT DOWN LEFT A B START SELECT F6 B >/dev/null

sleep 0.8
if ! kill -0 "${APP_PID}" 2>/dev/null; then
  echo "[error] App exited unexpectedly after non-exit actions"
  tail -n 80 "${LOG_FILE}" || true
  exit 3
fi

echo "[info] Injecting ESC to request shutdown"
./scripts/inject_input.sh -p "${INPUT_FILE}" ESC >/dev/null

for _ in $(seq 1 25); do
  if ! kill -0 "${APP_PID}" 2>/dev/null; then
    echo "[ok] App exited after ESC as expected"
    wait "${APP_PID}" || true
    exit 0
  fi
  sleep 0.1
done

echo "[error] App did not exit after ESC"
tail -n 80 "${LOG_FILE}" || true
exit 4
