# SnakeGB Logging Guide

Last updated: 2026-03-01

## Build Modes

- `release`: runtime logs are silent for `snakegb.*` categories.
- `dev` (`RelWithDebInfo`): summary logs only.
- `debug`: summary + detailed traces.

## Category Map

- `snakegb.state`: app/session state transitions, lifecycle summaries.
- `snakegb.audio`: music mode/track transitions and detailed cue traces.
- `snakegb.input`: routed input summaries and detailed routing traces.
- `snakegb.inject`: runtime input injection setup/failures and unknown tokens.
- `snakegb.level`: level loading/fallback events.
- `snakegb.replay`: replay save/load anomalies and replay diagnostics.

## Severity Usage

- `qCInfo`: summary logs intended for `dev`.
- `qCDebug`: high-volume details intended for `debug` only.
- `qCWarning`: anomalous but recoverable paths.

## QML Logging

QML controllers must use the shared `UiLog.qml` helper and avoid direct `console.log(...)`.

Current migration scope:

- `UiInputController.qml`
- `UiActionRouter.qml`
- `UiDebugController.qml`

## Practical Rules

- Do not log per-button `press/release` in `dev`.
- Keep `dev` focused on routed actions, semantic long-press paths, and ignored/failed routes.
- Keep per-cue audio playback logs (`beep`, `score cue`, `crash`) in `debug` only.

## Override Example

Use `QT_LOGGING_RULES` to override defaults temporarily:

```bash
QT_LOGGING_RULES="snakegb.input.debug=true;snakegb.audio.debug=true" ./build/debug/SnakeGB
```
