# UI Decoupling And Naming Plan

## Purpose
- Define the current UI decoupling baseline after the recent Shell/Screen split.
- Record the next-stage UI architecture targets so future refactors follow one plan instead of ad-hoc cleanup.
- Establish naming rules for QML components, controller objects, helper modules, and local layout ids.

## Current State

### What Is Already In Good Shape
- `Shell.qml` and `ScreenView.qml` are no longer directly coupled.
- `ShellBridge.qml` provides an abstract bridge for hardware-style input and shell-only interactions.
- `ScreenView.qml` owns top-level screen composition and z-ordering.
- Overlay/modal UI has started to move into reusable components such as `ModalSurface`, `ModalTextPanel`, `ModalChoiceCard`, and `LevelUpModal`.

### Main Remaining Coupling
- `main.qml` is still a large UI controller.
- Input routing, debug token routing, Konami handling, static debug switching, OSD triggering, and runtime action dispatch all still live in `main.qml`.
- `ScreenView.qml` still mixes screen composition with presentation helpers such as rarity labels, buff labels, readable ink selection, and theme-derived display rules.
- Page layers still depend directly on `gameLogic` fields and sometimes string-based `dispatchUiAction(...)` commands.

## Refactor Goals

### Goal 1: Keep Shell And Screen Separate
- `Shell.qml` must remain a shell-only component.
- `ScreenView.qml` must remain a screen-only component.
- Communication between shell hardware UI and app/runtime UI must continue to go through a bridge/controller layer, not direct child-object access.

### Goal 2: Shrink `main.qml`
- `main.qml` should become a composition root, not a behavior dump.
- It should mainly wire together:
  - runtime object(s)
  - shell object
  - screen object
  - controller/bridge objects
- Input routing, debug routing, and long-press semantics should move out of `main.qml`.

### Goal 3: Make `ScreenView.qml` A Pure Screen Assembler
- `ScreenView.qml` should own screen composition, shared screen tokens, and layer ordering.
- Business-ish presentation helpers should move into dedicated helper modules or presenter-style objects.
- `ScreenView.qml` should not keep growing as the place for every UI rule.

### Goal 4: Reduce Direct `gameLogic` Reach
- Leaf pages should consume smaller, purpose-specific inputs wherever practical.
- Prefer view-facing data or focused controller methods over broad direct reads from `gameLogic`.
- Avoid expanding stringly-typed UI actions in leaf layers.

## Target Architecture

### Composition Root
- `main.qml`
- Responsibility:
  - instantiate shell, screen, runtime, and controller objects
  - connect high-level signals
  - avoid owning route logic and page semantics

### Shell Layer
- `Shell.qml`
- child shell controls
- `ShellBridge.qml`
- Responsibility:
  - shell visuals
  - shell-only hardware interaction signals
  - pressed-state reflection

### UI Controller Layer
- New target objects to introduce over time:
  - `UiActionRouter`
  - `DebugTokenRouter`
  - `InputPressController`
  - `OverlayStateController` if needed
- Responsibility:
  - map input -> UI action
  - isolate debug-only routing
  - own long-press and combo semantics
  - reduce logic in `main.qml`

### Screen Layer
- `ScreenView.qml`
- Responsibility:
  - top-level screen composition
  - screen layer ordering
  - shader composition
  - assembling state/page/modal layers

### Presenter / Helper Layer
- Future split targets:
  - `ScreenThemeTokens.js`
  - `PowerMeta.js`
  - `ReadabilityRules.js`
- Responsibility:
  - palette-derived UI tokens
  - rarity/buff/power naming
  - readable foreground selection

### Leaf UI Layer
- `MenuLayer.qml`
- `WorldLayer.qml`
- `LibraryLayer.qml`
- `MedalRoom.qml`
- `OverlayLayer.qml`
- `StaticDebugLayer.qml`
- `IconLabLayer.qml`
- Responsibility:
  - render a specific screen/page state
  - avoid taking over global routing responsibility

## Naming Rules

### General Rules
- Names should describe responsibility, not implementation accident.
- Prefer one naming grammar per category instead of mixed styles.
- Avoid names that only make sense in the file they came from if the object is reusable.

### Component Names
- Reusable visual building blocks should use object-like names.
- Good:
  - `LevelUpModal`
  - `ReplayBanner`
  - `BuffStatusPanel`
  - `ModalSurface`
- Avoid vague container names for reusable files.
- Avoid resurrecting `Game*` prefixes unless the file is truly domain-specific and that prefix adds meaning.

### Controller / Bridge Names
- Controller-like objects should sound behavioral.
- Preferred suffixes:
  - `Router`
  - `Controller`
  - `Bridge`
  - `Presenter`
- Good:
  - `UiActionRouter`
  - `DebugTokenRouter`
  - `InputPressController`
  - `ShellBridge`

### Signal Names
- Use one consistent signal grammar per object.
- Prefer:
  - `...Triggered()` for discrete actions
  - `...Pressed()` / `...Released()` for press lifecycle
  - `...Changed(...)` only for state changes
- Avoid mixing:
  - `Requested`
  - `Began`
  - `Ended`
  - `Clicked`
  inside the same abstraction unless the distinction is deliberate and necessary.

### Local Layout Ids
- Use names that reflect role inside the component.
- Prefer:
  - `titleBar`
  - `actionBar`
  - `choiceList`
  - `choiceCardHeight`
  - `cardsArea`
- Avoid overly generic ids like:
  - `content1`
  - `box`
  - `panel2`
- Avoid role drift where `headerPanel` is really a title bar or `footerPanel` is really an action bar.

### Theme / Helper Names
- Theme-derived helpers should sound like token groups or rules, not random utility functions.
- Prefer future names like:
  - `screenTheme`
  - `screenTokens`
  - `powerMeta`
  - `readabilityRules`
- Avoid continuing to grow large files with many unrelated helper functions under generic names.

## Immediate Refactor Priorities

### Priority 1: Extract Controller Logic From `main.qml`
- Move input routing to a dedicated router object.
- Move debug token handling to a dedicated router object.
- Move long-press state handling out of the composition root.

### Priority 2: Normalize ShellBridge Naming
- Unify signal naming grammar in `ShellBridge.qml`.
- Make bridge signal names clearly separate:
  - discrete actions
  - press lifecycle
  - shell-only interactions

### Priority 3: Split Presentation Helpers From `ScreenView.qml`
- Move rarity/buff/power labeling and readable-ink rules out of `ScreenView.qml`.
- Keep `ScreenView.qml` focused on visual composition and shared screen-level tokens only.

### Priority 4: Reduce Leaf Access To Raw `gameLogic`
- Start with page layers and overlays.
- Introduce narrower inputs where direct `gameLogic` reach is excessive.

## Acceptance Criteria

### Decoupling
- `main.qml` is primarily composition and top-level wiring.
- `Shell.qml` and `ScreenView.qml` stay isolated and only interact through explicit interfaces.
- No direct access from `main.qml` to shell internal child objects.
- No new direct shell/screen object references added outside the bridge/controller layer.

### Naming
- New reusable components follow the naming rules in this document.
- New controller-like objects use behavioral suffixes consistently.
- Signal grammar is consistent within each abstraction.
- Refactors should improve naming clarity instead of preserving legacy local names by default.

## Refactor Order
1. Extract `UiActionRouter` from `main.qml`.
2. Extract `DebugTokenRouter` from `main.qml`.
3. Normalize `ShellBridge.qml` signal names and update call sites.
4. Split `ScreenView.qml` presentation helpers into dedicated helper modules.
5. Reduce raw `gameLogic` reach in leaf page layers.

## Scope Guardrails
- Do not mix visual polish-only tweaks into architecture commits unless the refactor requires them.
- Do not rename broadly without also clarifying ownership or responsibility.
- Prefer small architectural steps that leave the app runnable after each commit.
