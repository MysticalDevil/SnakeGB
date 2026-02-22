#!/usr/bin/env bash
set -euo pipefail

BUILD_DIR="${1:-build-debug}"
if [[ $# -gt 0 ]]; then
  shift
fi

if [[ ! -f "${BUILD_DIR}/compile_commands.json" ]]; then
  echo "[clang-tidy-cache] missing ${BUILD_DIR}/compile_commands.json" >&2
  echo "[clang-tidy-cache] run: cmake -S . -B ${BUILD_DIR} -G Ninja -DCMAKE_BUILD_TYPE=Debug" >&2
  exit 2
fi

mapfile -t INPUT_FILES < <(printf '%s\n' "$@")
if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
  mapfile -t INPUT_FILES < <(git diff --name-only -- '*.cpp' '*.cc' '*.cxx' '*.h' '*.hpp' | sort -u)
fi

if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
  echo "[clang-tidy-cache] no C/C++ files to check"
  exit 0
fi

DB_DIR="${BUILD_DIR}/.clang-tidy-db"
CACHE_DIR="${BUILD_DIR}/.clang-tidy-cache"
mkdir -p "${DB_DIR}" "${CACHE_DIR}"

jq 'map(.command |= gsub(" -mno-direct-extern-access"; ""))' \
  "${BUILD_DIR}/compile_commands.json" > "${DB_DIR}/compile_commands.json"

TIDY_VERSION="$(clang-tidy --version | tr '\n' ' ')"
CFG_HASH="nocfg"
if [[ -f .clang-tidy ]]; then
  CFG_HASH="$(sha256sum .clang-tidy | awk '{print $1}')"
fi

checked=0
skipped=0
failed=0

for rel in "${INPUT_FILES[@]}"; do
  [[ -z "$rel" ]] && continue
  if [[ ! -f "$rel" ]]; then
    continue
  fi

  abs="$(realpath "$rel")"
  cmd_line="$(jq -r --arg f "$abs" '.[] | select(.file == $f) | .command' "${DB_DIR}/compile_commands.json" | head -n 1)"
  if [[ -z "$cmd_line" || "$cmd_line" == "null" ]]; then
    echo "[clang-tidy-cache] skip (no compile command): $rel"
    skipped=$((skipped + 1))
    continue
  fi

  file_hash="$(sha256sum "$rel" | awk '{print $1}')"
  key="$(printf '%s\n%s\n%s\n%s\n' "$file_hash" "$cmd_line" "$CFG_HASH" "$TIDY_VERSION" | sha256sum | awk '{print $1}')"
  stamp="${CACHE_DIR}/${key}.ok"

  if [[ -f "$stamp" ]]; then
    echo "[clang-tidy-cache] hit: $rel"
    skipped=$((skipped + 1))
    continue
  fi

  echo "[clang-tidy-cache] run: $rel"
  if clang-tidy -p "${DB_DIR}" "$rel"; then
    : > "$stamp"
    checked=$((checked + 1))
  else
    failed=$((failed + 1))
  fi

done

echo "[clang-tidy-cache] checked=${checked} skipped=${skipped} failed=${failed}"
if [[ $failed -ne 0 ]]; then
  exit 1
fi
