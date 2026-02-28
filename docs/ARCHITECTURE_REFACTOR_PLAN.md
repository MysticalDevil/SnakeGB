# SnakeGB Architecture Refactor Plan

Last updated: 2026-02-28
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
- `src/adapter/engine_adapter.cpp` is still large and mixes rule execution, persistence access, resource loading,
  timing, and UI-facing mapping.

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

## Phase A: Core extraction without behavior change [Partial]

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

Current status:
- rule/helper extraction into `src/core/` is real and already useful;
- `SessionCore` now exists and owns session state, queued input, snake body, and a dedicated snapshot type;
- but the full gameplay tick/rule pipeline is still split between adapter and core, so the extraction is still partial.

## Phase B: Adapter contraction [Completed]

Goal:
- Make adapter thin and explicit.

Tasks:
- Move non-rule infra calls from adapter body into dedicated services.
- Replace multi-method direct QML invocations with action-oriented adapter API.
- Remove remaining state magic numbers in QML (`AppState.*` only).

Acceptance:
- QML does not call rule internals directly.
- Adapter methods become orchestration-only.

Current status:
- adapter responsibilities have been split across focused translation units;
- action-oriented adapter routing is in place;
- hotspot file size reduction target is already met.

## Phase C: Headless reliability [Partial]

Goal:
- Make gameplay verifiable without GUI.

Tasks:
- Add headless core tests for deterministic replay, collision edge cases, buff interactions.
- Add replay consistency test (same seed + same input => same timeline).
- Keep input semantics matrix tests for shell/navigation compatibility.

Acceptance:
- Core tests pass in CI without GUI runtime.
- Input matrix + smoke tests remain green.

Current status:
- headless tests for rule/helpers and adapter seams exist and are valuable;
- but there is still no standalone full-session gameplay core running an entire session/replay without the adapter layer.

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

## 8. Current Status

This section is intentionally stricter than the earlier progress notes below. It reflects the current repository
state, not the desired end state.

### 8.1 Completed

- Refactor objectives are documented.
- Module boundaries and target layering are documented.
- Phase plan and acceptance KPIs are documented.
- Adapter contraction work is substantially implemented:
  - `GameLogic` has been split into focused adapter translation units.
  - action-oriented QML input routing is in place via `dispatchUiAction(...)`.
  - hotspot file size reduction target is met (`src/adapter/engine_adapter.cpp` is already well under 600 lines).
- Headless/supporting tests exist for:
  - core rule helpers
  - input semantics
  - UI action parsing/dispatch
  - level loading/apply/script runtime
  - library/choice model mapping

### 8.2 Partially Completed

- Phase A core extraction has started, but only as rule/helper extraction.
- deterministic rule code now lives in `src/core/`.
- session/runtime helpers are extracted.
- `SessionCore` and `state_snapshot.h` now exist as the first real session boundary.
- session state, input queue, and snake body ownership now live behind that core object.
- however, the main tick/rule pipeline still is not fully moved behind that core object.
- Phase C headless reliability is only partially complete.
  - rule/helper tests are in place and useful.
  - however, there is still no standalone full-session gameplay core that can run an entire game/replay headlessly.
- QML coupling reduction is improved, but not finished.
  - most interactive paths are action-routed.
  - however, QML still directly touches several `GameLogic` methods/properties and debug-only entry points.
- KPI progress is mixed.
  - file-size, symbolic state checks, and compatibility goals are in good shape.
  - true core replaceability and full headless session execution are not there yet.

### 8.3 Not Completed

- The minimal core command interface from Phase A is not implemented as one coherent core API
  (`enqueueDirection`, `tick`, `applyMetaAction`, `selectChoice` on a dedicated core object).
- The proposed `services` split in Section 3.3 is not implemented as dedicated `src/services/` modules.
- The refactor cannot yet be considered complete under the hard KPIs in Section 5, because:
  - the core still cannot run a full session and replay independently of the adapter/QML stack;
  - `GameLogic` still owns some gameplay-facing orchestration and debug/runtime entry points that would belong behind
    a true core/adapter boundary.

## 9. Deferred Low-Priority Items

These are explicitly deferred to keep the core/adapter refactor moving:

- Theme token harmonization across all pages and overlays
  - Some palette variants still show visual drift between Menu / Icon Lab / Catalog / Achievements.
  - Target: all pages consume one shared token contract with minimal per-page overrides.
  - Priority: **P3 (low)**, post-refactor stabilization.

- Visual parity review against `main` / latest stable tag
  - Run side-by-side screenshot matrix and tune only readability/consistency deltas.
  - Priority: **P3 (low)**.

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
  - score-to-tick-interval mapping rule
  - replay frame/value object types into shared core type header

### Phase B progress snapshot (2026-02-23)

- Runtime adapter translation units moved into `src/adapter/` to make core/adapter boundaries explicit.
- FSM helpers (`session_step`, `replay_timeline`) moved into `src/fsm/` and namespaced under `snakegb::fsm`.
  - consolidated per-session mutable data into `core::SessionState` (score, food, buffs, direction, obstacles, ticks)
  - added `core::session_runtime` wrappers that take `SessionState` to reduce adapter parameter sprawl
  - roguelike choice pool picking/runtime selection algorithm
  - weighted power-up selection policy
  - scripted level `onTick` runtime obstacle parsing/application
  - dynamic scripted-level fallback obstacle evolution
  - achievement unlock rule evaluation
  - magnet movement candidate selection
  - collision probing and collision outcome policy (while keeping haptic/signal side effects in adapter)
- Remaining Phase A focus:
  - continue shrinking adapter-owned rule branches into `GameSessionCore`-style interfaces.
  - keep signal/timer/QML contract unchanged during extraction.

### Phase B progress snapshot (2026-02-21)

- Added `GameLogic::dispatchUiAction(const QString &action)` as an action-oriented adapter entry for QML input routing.
- Main shell input routing in `src/qml/main.qml` now calls adapter actions instead of directly calling multiple
  `GameLogic` methods (`nextShellColor`, `toggleMusic`, `quit`, `quitToMenu`, `handleStart`, `handleSelect`,
  `handleBAction`, `deleteSave`, directional `move`).
- Back-path semantics are now unified through one adapter action path.
- `src/qml/ScreenView.qml` state checks no longer use numeric literals; all state predicates are now `AppState.*`.
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
- Scripted level runtime evaluation is extracted into `src/adapter/level_script_runtime.*`; behavior is covered by
  `AdapterLevelScriptRuntimeTest`.
- Ghost replay persistence (`ghost.dat` load/save + legacy compatibility) is extracted into
  `src/adapter/ghost_store.*`; behavior is covered by `AdapterGhostStoreTest`.
- Profile session-map decoding is extracted into `src/adapter/session_state.*`; behavior is covered by
  `AdapterSessionStateTest`.
- Fruit/medal library view-model mapping is extracted into `src/adapter/library_models.*`; behavior is covered by
  `AdapterLibraryModelsTest`.
- `GameLogic` constructor wiring is split into focused helpers (`setupAudioSignals`, `setupSensorRuntime`) to
  reduce entry-point coupling before further service extraction.
- Runtime simulation flow is split into dedicated translation units to contract `src/adapter/tick_driver.cpp`:
  - `src/adapter/board_state.cpp`: spawn and occupancy helpers
  - `src/adapter/consumption.cpp`: food/power-up consumption and buff effect application
  - `src/adapter/simulation.cpp`: collision/movement/post-tick simulation path
- QML-facing view/property mapping methods are now extracted into `src/adapter/view_model.cpp` so the main runtime
  adapter file can continue shrinking around orchestration logic.
- FSM state instantiation is now centralized in `src/fsm/state_factory.*`; `GameLogic` no longer constructs concrete
  `*State` classes directly, reducing adapter-to-state implementation coupling.
- UI action execution routing is extracted into `src/adapter/ui_action.*` dispatcher callbacks; `GameLogic` now binds
  orchestration lambdas instead of owning the large action switch.
- `GameLogic` implementation is now split into focused translation units:
  - `src/adapter/engine_adapter.cpp` (bootstrap + state bridge + device wiring)
  - `src/adapter/input_router.cpp` (QML/action input orchestration)
  - `src/adapter/tick_driver.cpp` (tick/runtime orchestration)
  - `src/adapter/session_state.cpp` (session metadata + level selection orchestration)
  - `src/adapter/level_flow.cpp` (level loading/apply + achievement/script triggers)
  - `src/adapter/persistence.cpp` (save/load snapshot + high-score/ghost persistence)
  - `src/adapter/choices.cpp` (roguelike choice generation/selection runtime)
  - `src/adapter/lifecycle.cpp` (restart/replay/pause/lazy FSM bootstrap flow)
- Added `src/adapter/profile_bridge.*` as a dedicated adapter seam for profile/session/stats
  operations, reducing direct `GameLogic -> ProfileManager` coupling across input/runtime/session/view units.
- Main hotspot file `src/adapter/engine_adapter.cpp` is reduced to ~270 lines, making review/merge conflicts significantly smaller
  while preserving the existing QML-facing interface.
- `CMakeLists.txt` and test targets now compile the same split units, keeping runtime/test code paths aligned.
- Session bootstrap/reset orchestration is further contracted in `src/adapter/session_state.cpp` via
  `resetTransientRuntimeState()` and `resetReplayRuntimeTracking()`, reducing duplicate mutable-state branches across
  restart/replay/resume paths before the remaining core-session extraction.
- Level/achievement orchestration is separated from session flow into `src/adapter/level_flow.cpp`, keeping
  level script/apply concerns isolated from lifecycle concerns.
- Persistence and replay snapshot paths are separated into `src/adapter/persistence.cpp`, reducing adapter
  coupling around profile/session/ghost I/O.
- Roguelike choice flow and lifecycle transitions are isolated in `src/adapter/choices.cpp` and
  `src/adapter/lifecycle.cpp`, shrinking `src/adapter/session_state.cpp` further and making future
  `GameSessionCore` extraction more mechanical.

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
