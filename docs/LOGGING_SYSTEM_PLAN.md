# NenoSerpent Logging System Plan

Last updated: 2026-03-01

## Purpose

This document defines the next logging cleanup for NenoSerpent.

The current runtime logs are useful for debugging, but they are still too ad hoc:

- build modes are only partially separated
- QML and C++ use different conventions
- most logs are plain `qInfo()` strings instead of categorized channels
- `dev` is noisier than it should be

The goal of this plan is to make logging predictable, filterable, and readable across:

1. `release`
2. `dev`
3. `debug`

## Desired Outcome

### Release

- silent by default
- fatal errors still terminate normally
- no routine runtime flow logs

### Dev

Keep only high-signal operational logs:

- state changes
- audio mode / track changes
- key routed actions
- long-press semantic transitions
- input injection setup and failures
- level/replay errors and unusual fallbacks

Do not keep:

- per-button press/release spam
- per-cue `beep` / `score cue` playback spam
- repeated low-level route chatter

### Debug

Enable everything needed for deep diagnosis:

- detailed button press/release
- route-level decisions
- cue-level audio playback
- deferred/rejected routing paths
- replay/level-step tracing when relevant

## Problems In The Current System

### 1. Build modes are not a full logging policy

`main.cpp` currently exposes `appLogMode` to QML, but this is still just a string flag.

There is no formal shared logging policy object or logging category layer.

### 2. C++ logs are still string-prefixed only

Current prefixes such as:

- `[StateFlow]`
- `[AudioFlow]`
- `[SensorFlow]`
- `[InputInject]`

help visually, but they are not proper `QLoggingCategory` channels.

That means:

- logs cannot be filtered precisely with Qt logging rules
- there is no centralized ownership of what belongs to which subsystem

### 3. `dev` is still too noisy

Current `dev` logging still shows too much input and audio detail.

Examples:

- `UiInputController.qml` still logs too many raw input events
- `SoundManager` still logs per-cue playback

This makes `dev` output less useful during normal iteration.

### 4. QML logging is not centralized enough

QML controllers currently decide their own logging style inline.

That causes:

- duplicated logging helpers
- inconsistent message wording
- difficulty tightening verbosity globally

## Target Logging Architecture

## Layer 1: categorized C++ logging

Introduce shared `QLoggingCategory` channels.

Minimum category set:

- `NenoSerpent.state`
- `NenoSerpent.audio`
- `NenoSerpent.input`
- `NenoSerpent.inject`
- `NenoSerpent.level`
- `NenoSerpent.replay`

Rules:

- new C++ runtime logs should use categories instead of raw prefixed `qInfo()`
- category names should describe subsystem ownership, not call-site details
- log strings should be short and structured

## Layer 2: explicit mode policy

Define a single policy for:

- which categories are enabled in `release`
- which categories are enabled in `dev`
- which categories are enabled in `debug`

This should be applied centrally from app startup instead of scattered conditionals.

Expected behavior:

- `release`: effectively silent
- `dev`: state/audio/input summary only
- `debug`: full runtime detail

## Layer 3: centralized QML logging helper

QML should not keep ad hoc `console.log(...)` patterns across controllers.

Instead:

- provide a shared QML logging helper or singleton
- keep one message style for input/controller/runtime logs
- use the same mode policy as C++

Expected QML channels:

- `input`
- `routing`
- `debug`

At minimum, `UiInputController`, `UiActionRouter`, and `UiDebugController` should share the same
helper.

## Migration Plan

## Phase 1: Logging categories and startup policy (Completed)

Goal:

- introduce `QLoggingCategory`
- centralize startup log rule selection

Tasks:

- add shared logging category definitions in C++
- route current major C++ subsystems to those categories
- add one startup function that applies mode-specific Qt logging rules

Acceptance:

- C++ logs use categories
- `release/dev/debug` enable distinct category sets

## Phase 2: `dev` noise reduction (Completed)

Goal:

- keep `dev` readable during normal gameplay iteration

Tasks:

- reduce QML input logging to routed actions, long-press semantics, and ignored/failed paths
- reduce `SoundManager` logs so per-cue details only appear in `debug`
- keep state changes, music changes, and injection failures visible in `dev`

Acceptance:

- `dev` log stream is short enough to read while manually testing
- raw press/release spam and cue spam are gone from `dev`

## Phase 3: QML logging helper extraction (Completed)

Goal:

- remove duplicated controller-local logging helpers

Tasks:

- introduce a shared QML logging utility
- migrate `UiInputController`
- migrate `UiActionRouter`
- migrate `UiDebugController`

Acceptance:

- QML controllers no longer duplicate logging helper logic
- message style is consistent across controllers

## Phase 4: Documentation and operator guidance (Completed)

Goal:

- keep runtime logging discoverable and stable

Tasks:

- add a short logging guide (`docs/LOGGING_GUIDE.md`)
- update README build-mode notes
- document category names and intended usage

Acceptance:

- developers can tell what `release/dev/debug` mean without reading code
- category names and expected verbosity are documented

## Validation Checklist

For logging changes:

1. `clang-format`
2. `clang-tidy`
3. build
4. tests
5. one real runtime smoke in `build/dev`
6. one real runtime smoke in `build/debug`

Manual validation should confirm:

- `release` stays quiet
- `dev` shows only summary-level logs
- `debug` shows detailed controller/audio traces

## Initial Scope Boundaries

This plan does **not** require:

- changing gameplay logic
- changing audio behavior itself
- changing UI appearance
- adding external log sinks or telemetry

The first objective is log structure and readability, not observability infrastructure.
