# SnakeGB Architecture Refactor Plan

Last updated: 2026-02-21
Scope: architecture baseline review + GameLogic core/adapter decoupling roadmap.

## 1. Executive Summary

Current state:
- The project has passed the "basically maintainable" line.
- Input semantics unification has progressed well.
- `GameLogic` is still a high-load class and remains the main coupling hotspot.

Key conclusion:
- The decoupling is **not enough yet** for a reusable pseudo-emulator shell.
- The next milestone is not "more feature work", but "extract a true game core and shrink adapter responsibilities".

## 2. Current Architecture Assessment

## 2.1 What is already good

- FSM is interface-driven (`IGameEngine`) and no longer tightly bound to one concrete state owner.
- Sound output is mostly event-driven and assembled in app wiring.
- Profile/save responsibilities are separated into manager-level components.
- Input semantics are normalized through a single action dispatch entry.

## 2.2 What is still overloaded

Primary hotspot:
- `src/game_logic.cpp` is still very large and mixes rule execution, persistence access, resource loading, timing, and UI-facing mapping.

Symptoms:
- One class owns too many behaviors and changes for unrelated reasons.
- QML still talks to many `GameLogic` methods directly.
- Partial magic-number state checks still exist in QML pages.

Risk:
- Any new game mode / level system / UI page increases regression surface.
- Reusing shell + screen + controls for another mini game will be expensive.

## 2.3 Scorecard

- Module boundary clarity: 7/10
- Replaceability of gameplay core: 5/10
- Testability of game rules (headless): 5/10
- QML coupling control: 6/10
- Extensibility for multi-game shell: 6/10

Overall: **5.8/10** (needs refactor before scaling).

## 3. Target Architecture (Core + Adapter)

## 3.1 Design goals

- Keep gameplay rules independent from QML presentation.
- Keep shell/input/navigation independent from a specific game implementation.
- Enable future multi-game integration with additive adapters.

## 3.2 Layer model

1. `core` (pure gameplay session core)
- Owns deterministic rules: movement, collision, scoring, buff, replay timeline.
- Exposes command API + state snapshot API.
- No QML dependency.
- Avoid direct persistence/device I/O.

2. `adapter` (Qt/QML boundary)
- Maps input actions to core commands.
- Maps core snapshot to QML-friendly properties/models.
- Owns Qt timers and UI timing policy.
- Owns integration with profile/audio/asset services.

3. `services` (infra)
- profile persistence service
- level data source / fallback provider
- audio event sink
- optional sensor provider

## 3.3 Proposed module split

- `src/core/`
  - `game_session_core.h/.cpp`
  - `state_snapshot.h`
  - `rules/` (`collision`, `buff_runtime`, `scoring`, `replay`)

- `src/adapter/`
  - `qml_game_adapter.h/.cpp` (final QML-facing entry)
  - `input_router_adapter.h/.cpp`
  - `profile_adapter.h/.cpp`

- `src/services/`
  - `level_repository.h/.cpp`
  - `audio_bus.h/.cpp`
  - `save_repository.h/.cpp`

Note:
- Existing `GameLogic` should be gradually reduced into adapter responsibilities, then renamed or retired.

## 4. Migration Plan (Atomic Steps)

## Phase A: Core extraction without behavior change

Goal:
- Introduce `GameSessionCore` and move tick/rule progression first.

Tasks:
- Define minimal core command interface (`enqueueDirection`, `tick`, `applyMetaAction`, `selectChoice`).
- Define immutable snapshot struct for render/query.
- Move collision/movement/score/buff update pipeline into core.
- Keep old signals and QML API unchanged via adapter mapping.

Acceptance:
- Existing gameplay behavior remains unchanged.
- Existing manual flows and scripts still pass.

## Phase B: Adapter contraction

Goal:
- Make adapter thin and explicit.

Tasks:
- Move non-rule infra calls from adapter body into dedicated services.
- Replace multi-method direct QML invocations with action-oriented adapter API.
- Remove remaining state magic numbers in QML (`AppState.*` only).

Acceptance:
- QML does not call rule internals directly.
- Adapter methods become orchestration-only.

## Phase C: Headless reliability

Goal:
- Make gameplay verifiable without GUI.

Tasks:
- Add headless core tests for deterministic replay, collision edge cases, buff interactions.
- Add replay consistency test (same seed + same input => same timeline).
- Keep input semantics matrix tests for shell/navigation compatibility.

Acceptance:
- Core tests pass in CI without GUI runtime.
- Input matrix + smoke tests remain green.

## 5. Hard Acceptance KPIs

Refactor considered complete only if all are met:

1. `GameLogic` (or replacement adapter) no longer contains core rule branches.
2. Core can run full session and replay in headless mode.
3. QML-facing API remains compatible for menu/game/pause/catalog/achievements/easter paths.
4. `GameLogic` file size shrinks significantly (target: implementation under 600 lines).
5. QML state checks use symbolic `AppState` only (no magic numbers).
6. Existing input semantics scripts and regression checks pass.

## 6. Risks and Mitigations

Risk 1: signal timing regressions during extraction.
- Mitigation: move logic first, keep signal emission contract unchanged in adapter.

Risk 2: save/replay compatibility break.
- Mitigation: keep data schema stable during Phase A/B; introduce migration only in dedicated commit.

Risk 3: large-bang refactor instability.
- Mitigation: atomic commits per slice, each with compile + focused validation.

## 7. Execution Strategy

Branch model:
- Work on dedicated branch: `refactor/gamelogic-core-adapter`.
- Keep one concern per commit:
  - commit 1: core interfaces + snapshot
  - commit 2: movement/collision pipeline move
  - commit 3: buff/runtime pipeline move
  - commit 4: adapter API cleanup
  - commit 5: tests + docs sync

Validation after each commit:
- build (debug + release)
- app boot smoke
- input semantics smoke/matrix
- targeted gameplay checks (pause/B/menu/level switch/replay trigger)

## 8. Documentation Status

- [x] Refactor objectives documented.
- [x] Module boundaries defined.
- [x] Phase plan and KPIs defined.
- [x] Phase A implementation started.
- [x] Phase B implementation completed.
- [x] Phase C test hardening completed.

### Phase A progress snapshot (2026-02-21)

- Extracted to `src/core`: `game_rules`, `buff_runtime`, `session_step`, `replay_timeline`, `level_runtime`,
  `achievement_rules`.
- `fsm/states.cpp` now delegates playing/replay frame progression to core helpers.
- `GameLogic` adapter now delegates:
  - roguelike chance evaluation
  - safe initial snake body generation
  - random free-spot selection for food/powerup spawn
  - free-spot board scanning for food/powerup spawn
  - level walls JSON-to-grid parsing
  - level JSON entry resolution/index normalization
  - level JSON envelope decoding from raw bytes
  - level count extraction from JSON bytes
  - dynamic scripted-level fallback obstacle evolution
  - achievement unlock rule evaluation
  - magnet movement candidate selection
  - collision probing (while keeping buff/shield side effects in adapter)
- Remaining Phase A focus:
  - continue shrinking adapter-owned rule branches into `GameSessionCore`-style interfaces.
  - keep signal/timer/QML contract unchanged during extraction.

### Phase B progress snapshot (2026-02-21)

- Added `GameLogic::dispatchUiAction(const QString &action)` as an action-oriented adapter entry for QML input routing.
- Main shell input routing in `src/qml/main.qml` now calls adapter actions instead of directly calling multiple
  `GameLogic` methods (`nextShellColor`, `toggleMusic`, `quit`, `quitToMenu`, `handleStart`, `handleSelect`,
  `handleBAction`, `deleteSave`, directional `move`).
- Back-path semantics are now unified through one adapter action path.
- `src/qml/GameScreen.qml` state checks no longer use numeric literals; all state predicates are now `AppState.*`.
- `Library`/`MedalRoom` list index writes are now routed via `dispatchUiAction(...)` instead of direct adapter
  method calls.
- QML-triggered haptic/feedback requests are now also action-routed, so interactive QML calls are standardized on
  `dispatchUiAction(...)`.
- Action string parsing is extracted into `src/adapter/ui_action.*`; `GameLogic::dispatchUiAction` now delegates
  parsing and keeps only semantic dispatch.
- Back-button state semantics are extracted into `src/adapter/input_semantics.*`; adapter behavior is covered by
  `AdapterSemanticsTest`.
- Level resource loading (`QFile` + bytes handoff) is extracted into `src/adapter/level_loader.*`; behavior is
  covered by `AdapterLevelLoaderTest`.
- Level apply/fallback decision flow is extracted into `src/adapter/level_applier.*`; behavior is covered by
  `AdapterLevelApplierTest`.

### Phase C progress snapshot (2026-02-21)

- Added headless core-focused tests in `tests/test_core_rules.cpp`:
  - `buff_runtime` rules (food scoring/duration/shrink invariants)
  - `replay_timeline` deterministic tick application (input + choice frame playback behavior)
- Expanded `core-rules-tests` linkage in `CMakeLists.txt` to include `src/core/buff_runtime.cpp` and
  `src/core/replay_timeline.cpp`.
- Verification passed:
  - `ctest --output-on-failure` (GameLogicTest + CoreRulesTest)
  - `./scripts/input_semantics_matrix_wayland.sh` (input semantics compatibility matrix)
- Added `AdapterTest` (`tests/test_ui_action_parser.cpp`) to validate parser behavior for known/unknown/indexed
  actions in headless CI.
