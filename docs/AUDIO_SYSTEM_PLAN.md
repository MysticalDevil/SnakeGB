# Audio System Upgrade Plan

Last updated: 2026-03-01

## Purpose

This document defines the next-stage audio architecture for SnakeGB.

The current audio path is functional but still too coupled to individual call sites.
Playback intent, bus policy, and asset selection are not yet modeled as first-class concepts.

The goal of this plan is to upgrade the audio system from "play a sound here" to a clear layered design:

1. `AudioEvent` intent layer
2. `AudioBus` / mixer policy layer
3. cue/theme data layer

This plan is intentionally separate from the completed architecture refactor plan.
That plan focused on session/core/adapter boundaries.
This one focuses on audio system structure and future extensibility.

## Current Problems

### 1. Playback intent is spread across the codebase

Different parts of the app still trigger sound/haptic behavior from local context:

- QML controllers
- adapter/controller logic
- boot/menu/game transitions

That makes it hard to:

- audit what sounds exist
- change behavior consistently
- add platform-specific routing
- add policy such as throttling or ducking

### 2. Bus policy is too implicit

We already have service-level audio pieces, but not a fully explicit mixer policy.

Missing or incomplete concepts include:

- separate volume domains
- event priority
- cooldown / de-duplication
- ducking between music and transient cues

### 3. Cue selection is still too code-driven

Sound choice is still too tightly tied to runtime code paths.

That makes it harder to:

- tune sounds without code edits
- add theme/palette-dependent variants
- adjust gain/pitch/cooldown centrally

## Target Architecture

### Layer 1: `AudioEvent`

Introduce a typed event surface that represents playback intent.

Examples:

- `BootStart`
- `BootDone`
- `UiMove`
- `UiConfirm`
- `UiBack`
- `UiShellToggle`
- `UiPaletteShift`
- `GameEat`
- `GamePowerUp`
- `GameCrash`
- `GamePause`
- `GameResume`
- `ReplayEnter`
- `ReplayExit`
- `BgmMenu`
- `BgmGame`

Rules:

- UI/controller/runtime code should emit `AudioEvent`, not directly choose clips
- event naming should reflect intent, not implementation detail
- events should be stable enough to survive asset swaps

### Layer 2: `AudioBus` / mixer policy

The bus layer consumes `AudioEvent` and decides how to play it.

Expected responsibilities:

- route events to `music`, `sfx`, `ui`, or future domains
- apply volume policy
- throttle repeated events
- resolve priority conflicts
- apply ducking rules

Expected future volume groups:

- `master`
- `music`
- `sfx`
- `ui`

This layer should be the only place that knows about playback policy.

### Layer 3: cue/theme data

Map `AudioEvent` to concrete playback data.

Possible configuration fields:

- clip id / resource path
- output bus
- gain
- pitch variance
- cooldown
- loop flag
- one-shot flag
- platform gates
- theme variant

This allows sound tuning without reworking gameplay/controller code.

## Implementation Phases

### Phase 1: Event Surface

Introduce a typed `AudioEvent` API and route existing playback through it.

Scope:

- add `src/audio/event.h`
- centralize event emission
- keep audible behavior unchanged

Acceptance:

- runtime code no longer chooses concrete clips at call sites
- event routing is the single public playback intent surface

### Phase 2: Bus Policy

Extend `AudioBus` into a clearer mixer/policy layer.

Scope:

- explicit bus groups
- event cooldown rules
- simple priority handling
- music vs transient policy hooks

Acceptance:

- event routing and playback policy are separate concerns
- repeated UI events can be throttled centrally

### Phase 3: Data-Driven Cues

Move cue mapping into configuration-driven data.

Scope:

- event -> cue table
- optional theme-specific override table
- central gain/cooldown tuning

Acceptance:

- changing a cue mapping does not require touching gameplay/controller code

### Phase 4: Advanced Audio Behavior

Only after phases 1-3 are stable.

Possible additions:

- ducking
- random pitch variance
- richer replay/menu/game transitions
- platform-specific differences
- haptic/audio coordination

## Recommended Immediate Next Step

Implement Phase 1 first:

- create `AudioEvent`
- stop direct clip selection at higher layers
- route all playback intent through a single event entry point

This is the safest and highest-leverage change because it improves structure without changing audible behavior.

## Non-Goals

This plan does not require:

- immediate new sound assets
- redesigning the whole music system first
- platform-specific DSP work
- advanced procedural audio in the first pass

## Success Criteria

This audio upgrade should be considered structurally successful when:

1. gameplay/UI code emits intent, not clip ids
2. mixer policy lives in one place
3. cue selection is data-driven or centrally declared
4. future sound changes do not require touching unrelated logic layers
