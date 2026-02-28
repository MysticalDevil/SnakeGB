#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FOCUS_SCRIPT="${FOCUS_SCRIPT:-${ROOT_DIR}/scripts/palette_capture_focus.sh}"
MATRIX_SCRIPT="${MATRIX_SCRIPT:-${ROOT_DIR}/scripts/palette_capture_matrix.sh}"

OUT_DIR="${1:-/tmp/snakegb_palette_review}"
HTML_OUT="${HTML_OUT:-${OUT_DIR}/index.html}"
FOCUS_TARGETS="${FOCUS_TARGETS:-menu,game,dbg-replay-buff,dbg-choice}"
MATRIX_TARGETS="${MATRIX_TARGETS:-menu,achievements,catalog,icons}"
PALETTES="${PALETTES:-0,1,2,3,4}"
POST_NAV_WAIT="${POST_NAV_WAIT:-1.8}"
MONTAGE_FONT="${MONTAGE_FONT:-$(fc-match -f '%{file}\n' 'DejaVu Sans' | head -n 1)}"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[error] Missing command: $1"
    exit 1
  fi
}

need_cmd bash
need_cmd fc-match
need_cmd montage
need_cmd identify

mkdir -p "${OUT_DIR}/focus" "${OUT_DIR}/matrix" "${OUT_DIR}/sheets"

IFS=',' read -r -a PALETTE_LIST <<<"${PALETTES}"
IFS=',' read -r -a FOCUS_LIST <<<"${FOCUS_TARGETS}"
IFS=',' read -r -a MATRIX_LIST <<<"${MATRIX_TARGETS}"

for palette in "${PALETTE_LIST[@]}"; do
  echo "[round] focus palette=${palette}"
  PALETTE_STEPS="${palette}" TARGETS="${FOCUS_TARGETS}" POST_NAV_WAIT="${POST_NAV_WAIT}" \
    "${FOCUS_SCRIPT}" "${OUT_DIR}/focus"

  focus_inputs=()
  for target in "${FOCUS_LIST[@]}"; do
    focus_inputs+=("${OUT_DIR}/focus/snakegb_${target}_p${palette}.png")
  done
  montage -font "${MONTAGE_FONT}" "${focus_inputs[@]}" -tile 2x -geometry +8+8 "${OUT_DIR}/sheets/focus_p${palette}.png"
done

TARGETS="${MATRIX_TARGETS}" PALETTES="${PALETTES}" POST_NAV_WAIT="${POST_NAV_WAIT}" \
  "${MATRIX_SCRIPT}" "${OUT_DIR}/matrix"

for target in "${MATRIX_LIST[@]}"; do
  matrix_inputs=()
  for palette in "${PALETTE_LIST[@]}"; do
    matrix_inputs+=("${OUT_DIR}/matrix/palette_${palette}_${target}.png")
  done
  montage -font "${MONTAGE_FONT}" "${matrix_inputs[@]}" -tile 5x -geometry +8+8 "${OUT_DIR}/sheets/matrix_${target}.png"
done

{
  echo '<!doctype html>'
  echo '<html lang="en">'
  echo '<head>'
  echo '  <meta charset="utf-8">'
  echo '  <meta name="viewport" content="width=device-width, initial-scale=1">'
  echo '  <title>SnakeGB Palette Review</title>'
  echo '  <style>'
  echo '    :root { color-scheme: light; }'
  echo '    body { margin: 0; font-family: "Trebuchet MS", "Segoe UI", sans-serif; background: #e7ead8; color: #22301d; }'
  echo '    main { max-width: 1200px; margin: 0 auto; padding: 24px; }'
  echo '    h1, h2 { margin: 0 0 12px; }'
  echo '    p { margin: 0 0 16px; color: #43533d; }'
  echo '    section { margin: 0 0 28px; padding: 18px; background: #f5f7eb; border: 1px solid #a9b38b; border-radius: 10px; }'
  echo '    .sheet { margin: 0 0 20px; }'
  echo '    .sheet img { width: 100%; height: auto; display: block; border: 1px solid #93a170; border-radius: 8px; background: #dde3ca; }'
  echo '    .sheet-title { margin: 0 0 8px; font-size: 14px; font-weight: 700; letter-spacing: 0.04em; text-transform: uppercase; }'
  echo '  </style>'
  echo '</head>'
  echo '<body>'
  echo '  <main>'
  echo '    <h1>SnakeGB Palette Review</h1>'
  echo "    <p>Focus targets: ${FOCUS_TARGETS} | Matrix targets: ${MATRIX_TARGETS} | Palettes: ${PALETTES}</p>"
  echo '    <section>'
  echo '      <h2>Focus Sheets</h2>'
  for palette in "${PALETTE_LIST[@]}"; do
    echo '      <div class="sheet">'
    echo "        <div class=\"sheet-title\">Focus Palette ${palette}</div>"
    echo "        <img src=\"sheets/focus_p${palette}.png\" alt=\"Focus palette ${palette}\">"
    echo '      </div>'
  done
  echo '    </section>'
  echo '    <section>'
  echo '      <h2>Matrix Sheets</h2>'
  for target in "${MATRIX_LIST[@]}"; do
    echo '      <div class="sheet">'
    echo "        <div class=\"sheet-title\">${target}</div>"
    echo "        <img src=\"sheets/matrix_${target}.png\" alt=\"Matrix ${target}\">"
    echo '      </div>'
  done
  echo '    </section>'
  echo '  </main>'
  echo '</body>'
  echo '</html>'
} > "${HTML_OUT}"

echo "[ok] Review capture complete: ${OUT_DIR}"
for sheet in "${OUT_DIR}"/sheets/*.png; do
  dims="$(identify -format '%wx%h' "${sheet}")"
  echo "[ok] $(basename "${sheet}") ${dims}"
done
echo "[ok] $(basename "${HTML_OUT}")"
