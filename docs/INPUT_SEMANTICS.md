# Input Semantics Review and Unification Plan

## Scope
This document defines a unified input model for the current SnakeGB project and future multi-game "pseudo emulator" expansion.

Goals:
- Keep control semantics stable across pages and game states.
- Reduce side effects from hidden shortcuts and debug entry paths.
- Make future game integration additive instead of rewriting key handling.

## Progress Tracking

Last updated: 2026-02-21

- [x] Branch created for staged refactor (`refactor/input-semantics-phase1`).
- [x] Phase 1 (Part A): unified action dispatch entry added in QML (`dispatchAction` + action map).
- [x] Phase 1 (Part B): runtime input injection channel added (file queue / FIFO + token mapping).
- [x] Phase 1 (Part C): remove major direct key-to-logic entry points and add smoke script (`scripts/input_semantics_smoke.sh`).
- [x] Phase 2: introduce dedicated `InputRouter` abstraction + named state constants.
- [x] Phase 3 (Part A): destructive save-clear action now requires `START + SELECT` hold.
- [x] Phase 3: automated regression matrix for input semantics and easter no-side-effect rules.

---

## 1. Current Issues (Review Summary)

## 1.1 State-driven branching is too coupled
- Input behavior is tightly coupled to numeric `state` checks in QML.
- The same key may have different meanings in nearby states without explicit policy.

Risk:
- Regression risk grows when adding new states/pages/games.

## 1.2 Easter egg and gameplay share one route
- Konami-like input currently passes through the same path as normal gameplay input.
- Even after recent fixes, complexity remains high and easy to regress.

Risk:
- Hidden side effects can reappear (pause, mode switch, palette switch, etc.).

## 1.3 Confirm/Start semantics are mixed
- `A` and `START` both trigger “continue/start” in some paths.

Risk:
- Weak user mental model; harder to keep UX consistent across games.

## 1.4 Dangerous action mapped to single long press
- Save clear on `SELECT` long press is high-risk for accidental trigger.

Risk:
- Irrecoverable user data loss.

## 1.5 Return semantics are not fully unified
- `B`, `Back`, and `Esc` are close but not consistently equivalent in all contexts.

Risk:
- Inconsistent navigation when adding nested overlays and multi-game shell.

---

## 2. Unified Global Semantics (Target)

Define actions first, then map physical keys to actions.

## 2.1 Global actions
- `NavUp`, `NavDown`, `NavLeft`, `NavRight`
- `Primary` (confirm / main action)
- `Secondary` (back / cancel / secondary action)
- `Start` (session control)
- `Select` (meta/system operation)
- `Back` (platform/system back)

## 2.2 Recommended semantics
- `A` -> `Primary`
  - Confirm/enter/select in menu/list pages.
  - Main action inside game-specific context if applicable.
- `B` -> `Secondary`
  - Back/cancel in pages and overlays.
  - In gameplay: allowed as game-specific secondary action (e.g. palette switch), but in pause/gameover/page contexts it must always mean return/back.
- `START` -> `Start`
  - Start/continue/pause/resume lifecycle control only.
- `SELECT` -> `Select`
  - Meta operations only (level/mode/system panel).
  - Avoid destructive actions on single-key hold.
- `Back` / `Esc`
  - System-level back, equivalent to `Secondary` in UI contexts.
  - At top-level menu, may exit app.

---

## 3. State-by-State Input Matrix (Target)

## 3.1 Boot/Splash
- Accept only skip-safe inputs if needed.
- No destructive/system mutations.

## 3.2 Main Menu
- `A`: Start/confirm selected game/session.
- `B`: Exit app (or open quit confirm if required by platform policy).
- `Up/Down/Left/Right`: navigate menu entries/pages.
- `Select`: switch level/mode.
- `Start`: same as `A` (optional alias, keep explicit).

## 3.3 Gameplay
- DPad: movement.
- `A`: game-defined primary action (if exists).
- `B`: gameplay secondary action (current project uses palette switch).
- `Start`: pause/resume.
- `Select`: non-destructive meta action only.

## 3.4 Pause / Game Over
- `Start`: resume/restart.
- `B`: back to main menu.
- DPad: navigate options if option list exists.

## 3.5 Catalog / Achievements / Replay / Icon Lab
- DPad: list/grid navigation.
- `A`: inspect/confirm.
- `B`: back to main menu (or previous page if nested).
- `Start`: optional shortcut to main menu only if globally documented.
- `Select`: page-specific safe meta action only.

## 3.6 Hidden/Easter pages
- Must consume routed inputs while active.
- Exit action must be deterministic:
  - `B` and `Back` exit to main menu.
  - Optional sequence/F-key exits should also return to main menu.

---

## 4. Architecture Proposal (for Multi-Game Shell)

## 4.1 Introduce an action router
Create `InputRouter` with a single entry:
- Physical input -> normalized action -> dispatch chain.

Status:
- Implemented in `src/qml/main.qml` as layered action router (`QtObject`).
- Layer order now follows: `icon overlay -> state overlay -> page -> game -> shell`.
- Physical key/shell/touch/injected tokens all converge into `dispatchAction(...)`.

## 4.2 Dispatch priority
- Overlay layer
- Page layer
- Active game layer
- Shell fallback

Each layer returns `handled: true/false`.

## 4.3 Replace numeric states with named states
- Export symbolic enums to QML (e.g., `State.Menu`, `State.Playing`, `State.Pause`, ...).
- Remove magic numbers from key handling.

Status:
- Implemented with exported `AppState` enum (`SnakeGB 1.0`) and QML now routes by symbolic state constants.

## 4.4 Isolate easter/debug logic
- Keep easter detection in shell/frontend scope.
- Never directly mutate game state except explicit transition APIs.

---

## 5. Safety Policy

## 5.1 Destructive actions
- Save clear should require stronger confirmation:
  - Recommended: `Select + Start` hold + confirm prompt.
- Do not bind destructive action to single-key long press.

Status:
- Implemented as `Start + Select` hold to arm clear, followed by explicit `A` confirmation within a short timeout.

## 5.2 Timeout/reset for sequence inputs
- Sequence trackers (e.g., Konami) should have reset timeout and state constraints.
- Sequence in progress must not leak side effects into gameplay.

---

## 6. Migration Plan

## Phase 1 (Low-risk)
- Keep existing behavior but introduce action names in QML layer.
- Add explicit handling contract for each state/page.

## Phase 2 (Core refactor)
- Add `InputRouter` and symbolic state enums.
- Move page/game handlers to action-based API.

## Phase 3 (Hardening)
- Add regression scripts for:
  - state transition + input matrix checks
  - easter enter/exit no-side-effect checks
  - destructive action guard checks

Implemented:
- `scripts/input_semantics_matrix_wayland.sh`
  - Runs a deterministic Wayland matrix with isolated config per case.
  - Covers:
    - menu `B` exits app
    - menu `Esc` exits app
    - menu `Select` does not exit
    - gameplay pause + `B` returns to menu
    - icon lab (`F6`) + `B` returns to menu without crash
    - Konami sequence does not crash and remains recoverable

---

## 7. Acceptance Checklist

- Same key has same semantic intent across states.
- `B` / `Back` path is predictable and reversible.
- Easter/debug entry never changes gameplay state unexpectedly.
- All destructive actions require explicit confirmation.
- New game module can be added without editing global key condition spaghetti.

---

## 8. Automation Input Injection

Runtime input injection is available for non-focus-based UI automation.

## 8.1 Enable
Recommended (file queue mode):

```bash
SNAKEGB_INPUT_FILE=/tmp/snakegb-input.queue ./build-review/SnakeGB
```

Alternative (FIFO mode):

```bash
SNAKEGB_INPUT_PIPE=/tmp/snakegb-input.pipe ./build-review/SnakeGB
```

## 8.2 Send tokens
Use helper script:

```bash
./scripts/inject_input.sh -p /tmp/snakegb-input.queue UP UP DOWN DOWN LEFT RIGHT LEFT RIGHT B A
```

Supported tokens:
- `UP`, `DOWN`, `LEFT`, `RIGHT`
- `A`, `B`, `START`, `SELECT`
- `BACK`, `ESC`
- `F6` / `ICON`
- `COLOR` / `SHELL`
- `MUSIC`

Each token maps to unified `InputAction` dispatch in `main.qml`.
