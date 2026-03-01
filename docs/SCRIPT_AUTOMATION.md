# Script Automation Guide

Last updated: 2026-02-28

## Purpose

This document describes the shared script helper layers used by UI capture, palette review, and input semantics automation.

## Helper Layers

### `scripts/lib/script_common.sh`

Small generic shell helpers:

- `script_require_cmds <cmd...>`
- `script_split_csv_trimmed <csv> <output_array_name>`

Use this helper instead of re-declaring `need_cmd` or hand-rolling repeated CSV parsing in capture wrappers.

### `scripts/lib/ui_window_common.sh`

Shared Hyprland/Wayland app-session and window helpers:

- `ui_window_app_is_alive <pid>`
- `ui_window_stop_app <pid>`
- `ui_window_setup_isolated_config <template-prefix>`
- `ui_window_cleanup_isolated_config <dir>`
- `ui_window_kill_existing <app-bin>`
- `ui_window_wait_for_window <pid> <wait-seconds> <window-class> <window-title>`
- `ui_window_focus <window-address>`

This layer is intentionally transport-agnostic.
It manages process/window lifecycle only.
It does not know whether input will be sent by runtime input file, Hyprland shortcuts, adb, or other channels.

### `scripts/lib/ui_nav_runtime.sh`

Shared runtime helpers for:

- `scripts/ui/nav/capture.sh`
- `scripts/ui/nav/debug.sh`

Responsibilities:

- environment checks for Wayland
- capture lock acquisition
- build verification
- isolated config setup
- app launch + window discovery through `ui_window_common.sh`
- runtime input file token injection
- palette-step injection

Caller-facing outputs:

- `UI_NAV_APP_PID`
- `UI_NAV_WINDOW_ADDR`
- `UI_NAV_GEOM`
- `UI_NAV_CFG_TMP`

### `scripts/lib/input_matrix_common.sh`

Shared runtime helpers for:

- `scripts/input/semantics/matrix_wayland.sh`
- `scripts/input/semantics/cases_wayland.sh`

Responsibilities:

- per-case launch/cleanup
- app liveness expectations
- failure artifact capture
- Hyprland key transport

This layer now reuses `ui_window_common.sh` for process/window lifecycle but keeps its own input transport.

### `scripts/lib/capture_batch.sh`

Shared palette capture wrapper helpers:

- `capture_batch_require_script <capture-script>`
- `capture_batch_validate_palette_step <step>`
- `capture_batch_validate_output <png> [min-bytes]`
- `capture_batch_run_capture <capture-script> <target> <output> <palette-step> <isolated-config> <post-nav-wait> [palette-token]`

This layer is used by:

- `scripts/ui/palette/focus.sh`
- `scripts/ui/palette/matrix.sh`
- `scripts/ui/palette/single.sh`
- `scripts/ui/palette/debug_matrix.sh`

## High-Level Entry Points

### UI navigation and capture

- `scripts/ui/nav/capture.sh <target> <out.png>`
- `scripts/ui/nav/debug.sh <target>`

Both share target routing via `scripts/lib/ui_nav_targets.sh`.
That file now builds explicit target plans (`UI_NAV_TARGET_STEPS`, `UI_NAV_TARGET_POST_WAIT_OVERRIDE`) instead of calling token helpers directly.

### Palette review

- `scripts/ui/palette/focus.sh <out-dir>`
- `scripts/ui/palette/matrix.sh <out-dir>`
- `scripts/ui/palette/single.sh <palette-step> <out-dir> [targets]`
- `scripts/ui/palette/debug_matrix.sh <out-dir>`
- `scripts/ui/palette/review.sh <out-dir>`

`scripts/ui/palette/review.sh` delegates HTML generation to:

- `scripts/ui/palette/render_html.sh`

The review script should remain a shell orchestrator.
Large inline HTML should not be reintroduced there.

### Input semantics

- `scripts/input/semantics/smoke.sh`
- `scripts/input/semantics/matrix_wayland.sh`
- `scripts/input/semantics/cases_wayland.sh`

## Maintenance Rules

1. If a shell helper is reused in two or more scripts, move it into `scripts/lib/`.
2. Do not embed non-trivial Python/Perl/Node snippets inline inside shell scripts.
3. If a script needs another language, place it in its own file and invoke it directly.
4. Keep window/process lifecycle separate from input transport.
5. UI capture scripts must remain serial; `scripts/ui/nav/capture.sh` continues to own the global capture lock.
6. Keep target definition separate from execution. `scripts/lib/ui_nav_targets.sh` should declare steps, not directly call send helpers.

## Validation

When modifying script helpers, run the smallest relevant validation set first:

```bash
shellcheck -P SCRIPTDIR -x <touched scripts>
./scripts/ui/nav/capture.sh menu /tmp/script_smoke.png
FOCUS_TARGETS=menu MATRIX_TARGETS=menu PALETTES=0 ./scripts/ui/palette/review.sh /tmp/script_review_smoke
```

For input semantics helper changes, also run:

```bash
./scripts/input/semantics/smoke.sh
```
