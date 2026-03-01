#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/ui.sh nav-capture <target> <out.png>
  ./scripts/ui.sh nav-debug <target>
  ./scripts/ui.sh self-check
  ./scripts/ui.sh palette-focus <out-dir>
  ./scripts/ui.sh palette-matrix <out-dir>
  ./scripts/ui.sh palette-single <palette-step> <out-dir> [targets]
  ./scripts/ui.sh palette-debug-matrix <out-dir>
  ./scripts/ui.sh palette-review <out-dir>
EOF
}

subcommand="${1:-}"
if [[ -z "${subcommand}" ]]; then
  usage
  exit 1
fi
shift

case "${subcommand}" in
  nav-capture)
    exec "${ROOT_DIR}/ui/nav/capture.sh" "$@"
    ;;
  nav-debug)
    exec "${ROOT_DIR}/ui/nav/debug.sh" "$@"
    ;;
  self-check)
    exec "${ROOT_DIR}/ui/self_check.sh" "$@"
    ;;
  palette-focus)
    exec "${ROOT_DIR}/ui/palette/focus.sh" "$@"
    ;;
  palette-matrix)
    exec "${ROOT_DIR}/ui/palette/matrix.sh" "$@"
    ;;
  palette-single)
    exec "${ROOT_DIR}/ui/palette/single.sh" "$@"
    ;;
  palette-debug-matrix)
    exec "${ROOT_DIR}/ui/palette/debug_matrix.sh" "$@"
    ;;
  palette-review)
    exec "${ROOT_DIR}/ui/palette/review.sh" "$@"
    ;;
  *)
    usage
    exit 1
    ;;
esac
