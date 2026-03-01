#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SOURCE_ICON="${ROOT_DIR}/src/qml/icon.svg"
RES_DIR="${ROOT_DIR}/android/res"
PLAYSTORE_DIR="${ROOT_DIR}/android/playstore"

if [[ ! -f "${SOURCE_ICON}" ]]; then
  echo "error: source icon not found: ${SOURCE_ICON}" >&2
  exit 1
fi

if ! command -v rsvg-convert >/dev/null 2>&1; then
  echo "error: rsvg-convert is required" >&2
  exit 1
fi

if ! command -v magick >/dev/null 2>&1; then
  echo "error: ImageMagick 'magick' is required" >&2
  exit 1
fi

mkdir -p "${PLAYSTORE_DIR}"

declare -A densities=(
  [mipmap-mdpi]=48
  [mipmap-hdpi]=72
  [mipmap-xhdpi]=96
  [mipmap-xxhdpi]=144
  [mipmap-xxxhdpi]=192
)

render_square() {
  local size="$1"
  local output="$2"
  rsvg-convert -w "${size}" -h "${size}" "${SOURCE_ICON}" -o "${output}"
}

render_round() {
  local size="$1"
  local output="$2"
  local tmp_file
  tmp_file="$(mktemp /tmp/nenoserpent-round-icon-XXXXXX.png)"
  render_square "${size}" "${tmp_file}"
  magick "${tmp_file}" \
    \( -size "${size}x${size}" xc:black -fill white -draw "circle $((size / 2)),$((size / 2)) $((size / 2)),0" \) \
    -compose CopyOpacity -composite "${output}"
  rm -f "${tmp_file}"
}

for density_dir in "${!densities[@]}"; do
  icon_size="${densities[${density_dir}]}"
  target_dir="${RES_DIR}/${density_dir}"
  mkdir -p "${target_dir}"
  render_square "${icon_size}" "${target_dir}/ic_launcher.png"
  render_round "${icon_size}" "${target_dir}/ic_launcher_round.png"
done

render_square 512 "${PLAYSTORE_DIR}/ic_launcher_512.png"

echo "generated Android launcher icons + playstore 512px asset"
