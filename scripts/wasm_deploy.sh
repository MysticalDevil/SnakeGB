#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

: "${QT_WASM_PREFIX:?Please set QT_WASM_PREFIX, e.g. ~/Qt/6.7.3/wasm_singlethread}"

QT_CMAKE_BIN="${QT_CMAKE_BIN:-${QT_WASM_PREFIX}/bin/qt-cmake}"
BUILD_DIR="${BUILD_DIR:-${PROJECT_ROOT}/build-wasm-local}"
CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}"
DIST_DIR="${DIST_DIR:-/tmp/snakegb-wasm-dist}"
SERVE="${SERVE:-1}"
PORT="${PORT:-8080}"

for cmd in cmake ninja; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
        echo "[error] Missing command: ${cmd}"
        exit 1
    fi
done

if [[ "${SERVE}" == "1" ]] && ! command -v python3 >/dev/null 2>&1; then
    echo "[error] Missing command: python3"
    exit 1
fi

if [[ ! -x "${QT_CMAKE_BIN}" ]]; then
    echo "[error] qt-cmake not found: ${QT_CMAKE_BIN}"
    exit 1
fi

echo "[info] Project: ${PROJECT_ROOT}"
echo "[info] QT_WASM_PREFIX=${QT_WASM_PREFIX}"
echo "[info] BUILD_DIR=${BUILD_DIR}"
echo "[info] CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"

"${QT_CMAKE_BIN}" \
    -S "${PROJECT_ROOT}" \
    -B "${BUILD_DIR}" \
    -G Ninja \
    -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
    -DSNAKEGB_OPTIMIZE_SIZE=ON

cmake --build "${BUILD_DIR}" --parallel

mkdir -p "${DIST_DIR}"
cp -f "${BUILD_DIR}/SnakeGB."{html,js,wasm} "${DIST_DIR}/"
if [[ -f "${BUILD_DIR}/qtloader.js" ]]; then
    cp -f "${BUILD_DIR}/qtloader.js" "${DIST_DIR}/"
fi
if [[ -f "${BUILD_DIR}/SnakeGB.data" ]]; then
    cp -f "${BUILD_DIR}/SnakeGB.data" "${DIST_DIR}/"
fi

echo "[info] WASM package copied to: ${DIST_DIR}"
echo "[info] Entry: ${DIST_DIR}/SnakeGB.html"

if [[ "${SERVE}" == "1" ]]; then
    echo "[info] Starting local web server at http://127.0.0.1:${PORT}/SnakeGB.html"
    echo "[info] Press Ctrl+C to stop"
    cd "${DIST_DIR}"
    exec python3 -m http.server "${PORT}" --bind 127.0.0.1
fi
