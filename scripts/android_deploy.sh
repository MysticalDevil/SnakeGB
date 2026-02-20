#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

: "${QT_ANDROID_PREFIX:?Please set QT_ANDROID_PREFIX, e.g. ~/dev/build-qt-android/build-android-arm64/qt-android-install}"

QT_CMAKE_BIN="${QT_CMAKE_BIN:-${QT_ANDROID_PREFIX}/bin/qt-cmake}"
ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-${HOME}/Android/Sdk}"
BUILD_DIR="${BUILD_DIR:-${PROJECT_ROOT}/build-android-local}"
CMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE:-Release}"
ANDROID_ABI="${ANDROID_ABI:-arm64-v8a}"
ANDROID_PLATFORM="${ANDROID_PLATFORM:-28}"
QT_HOST_PATH="${QT_HOST_PATH:-}"
QT_HOST_INFO_DIR="${QT_HOST_INFO_DIR:-}"
APP_ID="${APP_ID:-org.devil.snakegb}"
INSTALL_TO_DEVICE="${INSTALL_TO_DEVICE:-1}"
LAUNCH_AFTER_INSTALL="${LAUNCH_AFTER_INSTALL:-1}"

ANDROID_NDK_ROOT="${ANDROID_NDK_ROOT:-}"
if [[ -z "${ANDROID_NDK_ROOT}" ]]; then
  if [[ -d "${ANDROID_SDK_ROOT}/ndk" ]]; then
    ANDROID_NDK_ROOT="$(find "${ANDROID_SDK_ROOT}/ndk" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n1)"
  fi
fi

if [[ -z "${ANDROID_NDK_ROOT}" ]]; then
  echo "[error] ANDROID_NDK_ROOT is not set and no NDK found under ${ANDROID_SDK_ROOT}/ndk"
  exit 1
fi

if [[ -z "${QT_HOST_PATH}" ]]; then
  # Common for source-built Qt trees where host tools live next to qt-android-install.
  if [[ -d "$(dirname "${QT_ANDROID_PREFIX}")/qtbase" ]]; then
    QT_HOST_PATH="$(dirname "${QT_ANDROID_PREFIX}")/qtbase"
  else
    QT_HOST_PATH="${QT_ANDROID_PREFIX}"
  fi
fi

if [[ -z "${QT_HOST_INFO_DIR}" ]]; then
  QT_HOST_INFO_DIR="${QT_HOST_PATH}/lib/cmake/Qt6HostInfo"
fi

if [[ -z "${JAVA_HOME:-}" ]]; then
  if command -v javac >/dev/null 2>&1; then
    JAVAC_REAL="$(readlink -f "$(command -v javac)")"
    export JAVA_HOME="$(cd "$(dirname "${JAVAC_REAL}")/.." && pwd)"
  fi
fi

if [[ -n "${JAVA_HOME:-}" ]]; then
  export PATH="${JAVA_HOME}/bin:${PATH}"
fi

for cmd in cmake ninja keytool; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "[error] Missing command: ${cmd}"
    exit 1
  fi
done

if [[ ! -x "${QT_CMAKE_BIN}" ]]; then
  echo "[error] qt-cmake not found: ${QT_CMAKE_BIN}"
  exit 1
fi

if [[ ! -d "${ANDROID_SDK_ROOT}" ]]; then
  echo "[error] Android SDK not found: ${ANDROID_SDK_ROOT}"
  exit 1
fi

if [[ ! -d "${ANDROID_NDK_ROOT}" ]]; then
  echo "[error] Android NDK not found: ${ANDROID_NDK_ROOT}"
  exit 1
fi

echo "[info] Project: ${PROJECT_ROOT}"
echo "[info] QT_ANDROID_PREFIX=${QT_ANDROID_PREFIX}"
echo "[info] QT_HOST_PATH=${QT_HOST_PATH}"
echo "[info] ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}"
echo "[info] ANDROID_NDK_ROOT=${ANDROID_NDK_ROOT}"
echo "[info] JAVA_HOME=${JAVA_HOME:-<not set>}"

"${QT_CMAKE_BIN}" \
  -S "${PROJECT_ROOT}" \
  -B "${BUILD_DIR}" \
  -G Ninja \
  -DCMAKE_BUILD_TYPE="${CMAKE_BUILD_TYPE}" \
  -DANDROID_SDK_ROOT="${ANDROID_SDK_ROOT}" \
  -DANDROID_NDK="${ANDROID_NDK_ROOT}" \
  -DANDROID_ABI="${ANDROID_ABI}" \
  -DANDROID_PLATFORM="${ANDROID_PLATFORM}" \
  -DQT_HOST_PATH="${QT_HOST_PATH}" \
  -DQt6HostInfo_DIR="${QT_HOST_INFO_DIR}"

cmake --build "${BUILD_DIR}" --target apk --parallel

UNSIGNED_APK="$(find "${BUILD_DIR}/android-build/build/outputs/apk/release" -maxdepth 1 -type f -name '*-unsigned.apk' | head -n1)"
if [[ -z "${UNSIGNED_APK}" ]]; then
  echo "[error] Unsigned APK not found under ${BUILD_DIR}/android-build/build/outputs/apk/release"
  exit 1
fi

ANDROID_BUILD_TOOLS_DIR="${ANDROID_BUILD_TOOLS_DIR:-}"
if [[ -z "${ANDROID_BUILD_TOOLS_DIR}" ]]; then
  ANDROID_BUILD_TOOLS_DIR="$(find "${ANDROID_SDK_ROOT}/build-tools" -mindepth 1 -maxdepth 1 -type d | sort -V | tail -n1)"
fi

ZIPALIGN_BIN="${ZIPALIGN_BIN:-${ANDROID_BUILD_TOOLS_DIR}/zipalign}"
APKSIGNER_BIN="${APKSIGNER_BIN:-${ANDROID_BUILD_TOOLS_DIR}/apksigner}"
ADB_BIN="${ADB_BIN:-${ANDROID_SDK_ROOT}/platform-tools/adb}"

for tool in "${ZIPALIGN_BIN}" "${APKSIGNER_BIN}"; do
  if [[ ! -x "${tool}" ]]; then
    echo "[error] Missing Android build tool: ${tool}"
    exit 1
  fi
done

DEBUG_KEYSTORE_PATH="${DEBUG_KEYSTORE_PATH:-${HOME}/.android/debug.keystore}"
DEBUG_KEY_ALIAS="${DEBUG_KEY_ALIAS:-androiddebugkey}"
DEBUG_KEYSTORE_PASS="${DEBUG_KEYSTORE_PASS:-android}"
DEBUG_KEY_PASS="${DEBUG_KEY_PASS:-android}"

if [[ ! -f "${DEBUG_KEYSTORE_PATH}" ]]; then
  mkdir -p "$(dirname "${DEBUG_KEYSTORE_PATH}")"
  keytool -genkeypair -v \
    -keystore "${DEBUG_KEYSTORE_PATH}" \
    -storepass "${DEBUG_KEYSTORE_PASS}" \
    -alias "${DEBUG_KEY_ALIAS}" \
    -keypass "${DEBUG_KEY_PASS}" \
    -dname "CN=Android Debug,O=Android,C=US" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 >/dev/null 2>&1
fi

ALIGNED_APK="${ALIGNED_APK:-/tmp/${APP_ID}-${ANDROID_ABI}-aligned.apk}"
SIGNED_APK="${SIGNED_APK:-/tmp/${APP_ID}-${ANDROID_ABI}.apk}"

"${ZIPALIGN_BIN}" -f 4 "${UNSIGNED_APK}" "${ALIGNED_APK}"
"${APKSIGNER_BIN}" sign \
  --ks "${DEBUG_KEYSTORE_PATH}" \
  --ks-pass "pass:${DEBUG_KEYSTORE_PASS}" \
  --key-pass "pass:${DEBUG_KEY_PASS}" \
  --ks-key-alias "${DEBUG_KEY_ALIAS}" \
  --out "${SIGNED_APK}" \
  "${ALIGNED_APK}"
"${APKSIGNER_BIN}" verify "${SIGNED_APK}"

echo "[info] Signed APK: ${SIGNED_APK}"

if [[ "${INSTALL_TO_DEVICE}" == "1" ]]; then
  if [[ ! -x "${ADB_BIN}" ]]; then
    echo "[error] adb not found: ${ADB_BIN}"
    exit 1
  fi
  "${ADB_BIN}" install -r "${SIGNED_APK}"
  if [[ "${LAUNCH_AFTER_INSTALL}" == "1" ]]; then
    "${ADB_BIN}" shell monkey -p "${APP_ID}" -c android.intent.category.LAUNCHER 1 >/dev/null
    echo "[info] Launched: ${APP_ID}"
  fi
fi
