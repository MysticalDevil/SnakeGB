#!/usr/bin/env bash
set -euo pipefail

HTML_OUT="${1:?usage: render_palette_review_html.sh <output.html> <focus-targets> <matrix-targets> <palettes>}"
FOCUS_TARGETS="${2:?}"
MATRIX_TARGETS="${3:?}"
PALETTES="${4:?}"

mkdir -p "$(dirname "${HTML_OUT}")"

IFS=',' read -r -a PALETTE_LIST <<<"${PALETTES}"
IFS=',' read -r -a MATRIX_LIST <<<"${MATRIX_TARGETS}"

{
  cat <<EOF
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>NenoSerpent Palette Review</title>
  <style>
    :root { color-scheme: light; }
    body { margin: 0; font-family: "Trebuchet MS", "Segoe UI", sans-serif; background: #e7ead8; color: #22301d; }
    main { max-width: 1200px; margin: 0 auto; padding: 24px; }
    h1, h2 { margin: 0 0 12px; }
    p { margin: 0 0 16px; color: #43533d; }
    section { margin: 0 0 28px; padding: 18px; background: #f5f7eb; border: 1px solid #a9b38b; border-radius: 10px; }
    .sheet { margin: 0 0 20px; }
    .sheet img { width: 100%; height: auto; display: block; border: 1px solid #93a170; border-radius: 8px; background: #dde3ca; }
    .sheet-title { margin: 0 0 8px; font-size: 14px; font-weight: 700; letter-spacing: 0.04em; text-transform: uppercase; }
  </style>
</head>
<body>
  <main>
    <h1>NenoSerpent Palette Review</h1>
EOF
  printf '    <p>Focus targets: %s | Matrix targets: %s | Palettes: %s</p>\n' \
    "${FOCUS_TARGETS}" "${MATRIX_TARGETS}" "${PALETTES}"
  cat <<EOF
    <section>
      <h2>Focus Sheets</h2>
EOF
  for palette in "${PALETTE_LIST[@]}"; do
    cat <<EOF
      <div class="sheet">
        <div class="sheet-title">Focus Palette ${palette}</div>
        <img src="sheets/focus_p${palette}.png" alt="Focus palette ${palette}">
      </div>
EOF
  done
  cat <<EOF
    </section>
    <section>
      <h2>Matrix Sheets</h2>
EOF
  for target in "${MATRIX_LIST[@]}"; do
    cat <<EOF
      <div class="sheet">
        <div class="sheet-title">${target}</div>
        <img src="sheets/matrix_${target}.png" alt="Matrix ${target}">
      </div>
EOF
  done
  cat <<'EOF'
    </section>
  </main>
</body>
</html>
EOF
} > "${HTML_OUT}"
