# Audio System Upgrade Plan

Last updated: 2026-03-01

## Purpose

This document defines the next-stage audio architecture for NenoSerpent.

The current audio path is functional but still too coupled to individual call sites.
Playback intent, bus policy, and asset selection are not yet modeled as first-class concepts.

The goal of this plan is to upgrade the audio system from "play a sound here" to a clear layered design:

1. `AudioEvent` intent layer
2. `AudioBus` / mixer policy layer
3. score/cue/theme data layer
4. optional user-authored BGM layer

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

### 4. Music content is not yet extensible enough

The current system does not provide a clean path for:

- adding more BGM tracks without growing code complexity
- expressing retro music in a compact, editable format
- supporting user-authored BGM in a controlled way

For a Game Boy-inspired project, treating music as structured score data is a better fit than only relying on baked audio assets.

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

### Layer 4: score resources and synthesis

Prefer score resources as a first-class audio asset type.

Recommended model:

- short UI/game cues and boot sounds are authored as score/sequence data
- score resources are packed into app resources at build time
- runtime renders score data into playable PCM or streams synthesized audio directly

This is a better fit for retro handheld audio than treating every cue as a pre-rendered file.

Recommended first-wave uses:

- boot chirp
- menu confirm/back/move cues
- pause/game-over stingers
- short roguelike/choice cues

Longer BGM can follow after the event and bus layers are stable.

### Layer 5: user-authored BGM

Allow a controlled path for user-written BGM.

Recommended scope:

- users author music in the same supported score format
- custom files live outside the shipped resource pack
- runtime validates and loads them through a constrained import path
- custom BGM maps onto existing music events (`BgmMenu`, `BgmGame`, etc.)

This should be optional and sandboxed:

- invalid score files should fail safely
- unsupported commands should be rejected cleanly
- custom BGM should not bypass normal volume/bus policy

This makes the project extensible without tying gameplay logic to ad hoc audio file loading.

## Score Resource Strategy

### Preferred approach: runtime synthesis from score resources

Recommended default path:

- author score data in text/JSON resources
- package score data as normal app resources
- synthesize at runtime

Benefits:

- very small assets
- easy to edit and diff
- closer to retro hardware behavior
- flexible tempo/pitch/arrangement control
- good fit for future theme variants

### Alternative approach: build-time rendering

An alternative is to compile score data into PCM/WAV during the build and ship those rendered assets.

This is simpler at runtime but less flexible.

Use it only if:

- runtime synth complexity becomes a delivery blocker
- a particular platform needs pre-rendered fallback assets

### Recommended synthesis scope

Start small.

Waveforms/features worth supporting first:

- square wave
- optional second square voice
- noise channel
- simple envelope
- tempo
- note length / rest

Do not start with a full tracker.
The first version only needs enough expressive range to replace UI cues and simple BGM safely.

## Score Format Goals

The score format should be:

- text-friendly
- easy to diff in Git
- simple to validate
- expressive enough for retro cues and looped BGM

Possible fields:

- `tempo`
- `loop`
- `voices`
- `wave`
- `duty`
- `volume`
- `notes`

Example shape:

```json
{
  "tempo": 150,
  "loop": true,
  "voices": [
    {
      "wave": "square",
      "duty": 0.5,
      "volume": 0.8,
      "notes": [
        ["C5", 0.12],
        ["E5", 0.12],
        ["G5", 0.18],
        ["REST", 0.08]
      ]
    }
  ]
}
```

The exact syntax can change later; the important decision is to treat musical intent as structured resource data.

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

Current status:

- `Completed` for the initial event-surface milestone
- `src/audio/event.h` exists and runtime/FSM playback intent is routed through typed events
- `AudioBus` now consumes typed events through a single dispatch entry point
- audible behavior is still mapped to the existing beep/crash callbacks, so no cue redesign has been mixed into this phase

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

Current status:

- `Completed` for the initial bus-policy milestone
- `AudioBus` now owns event grouping, UI cooldown policy, and simple priority handling
- repeated `UiInteract` events are throttled centrally
- `Confirm` is allowed to override recent lower-priority UI interaction cues
- mixer-level ducking and richer group policy remain deferred to later audio phases

### Phase 3: Data-Driven Cues

Move cue mapping into configuration-driven data.

Scope:

- event -> cue table
- optional theme-specific override table
- central gain/cooldown tuning

Acceptance:

- changing a cue mapping does not require touching gameplay/controller code
- short cues can be represented as resource data rather than hard-coded playback logic

Current status:

- `Completed` for the initial cue-table milestone
- short cue mapping now lives in a centralized `AudioEvent -> CueSpec` table
- `AudioBus` consumes cue data instead of hard-coding per-event beep/crash values inline
- cue data is still compiled into code for now; external score/resource files remain part of later phases

### Phase 4: Score Resources and BGM Expansion

Add structured score resources and expand the number of BGM tracks.

Scope:

- define first score format
- add runtime synth or score renderer
- migrate boot/UI cues first
- introduce more BGM than the current minimal set
- add stable event-to-track routing for menu/game/replay states

Acceptance:

- at least the short cues are score-driven
- BGM can be expanded without wiring new code paths each time
- music routing remains event-driven

Current status:

- `Completed` for the initial score-cue milestone
- short confirmation and UI interaction cues now route through score-based cue ids instead of raw
  beep parameters
- `SoundManager` can render a minimal in-memory score sequence for score cues
- menu/game/replay music routing now selects score-backed tracks by track id
- the first longer classic chiptune-style menu BGM has replaced the earlier minimal placeholder loop
- score-backed tracks now use note/duration/duty data instead of inlined raw frequency pairs
- score data now loads from external Qt resource JSON rather than staying compiled into header constants
- a dedicated replay track has been added as the second BGM expansion step inside this phase
- user-authored score import remains the next unfinished step after resource-backed built-in tracks

### Phase 5: User BGM Import

Add a controlled user-authored BGM path.

Scope:

- file format validation
- import/load rules
- fallback behavior on invalid content
- mapping custom tracks into known music slots

Acceptance:

- user-written BGM can be loaded without touching gameplay code
- invalid files fail safely
- custom music still respects mixer policy and volume groups

Current status:

- `Partial`
- score-track loading now supports a controlled external override file for `menu`, `menu_alt`,
  `gameplay`, `gameplay_alt`, `replay`, and `replay_alt`
- the override path defaults to an app-data location and can be redirected with
  `NENOSERPENT_SCORE_OVERRIDE_FILE` for testing and manual iteration
- invalid or missing override content falls back to the built-in resource catalog safely
- the shell speaker now cycles the active built-in BGM variant (`A/B`) for the current music slot
- there is still no end-user import UX, per-track metadata policy, or cue override support yet

### Phase 6: Advanced Audio Behavior

Only after the earlier structural phases are stable.

Possible additions:

- ducking
- random pitch variance
- richer replay/menu/game transitions
- platform-specific differences
- haptic/audio coordination

Current status:

- `Partial`
- transient `UiInteract`, `Confirm`, `PowerUp`, and `Crash` events now trigger a simple music
  ducking policy through `AudioBus`
- the ducking decision lives in the bus/policy layer and is routed to `SoundManager` as a
  separate control signal
- richer mixer behavior, per-group gain controls, and transition-aware ducking remain unfinished

## Recommended Immediate Next Step

Implement Phase 1 first:

- create `AudioEvent`
- stop direct clip selection at higher layers
- route all playback intent through a single event entry point

This is the safest and highest-leverage change because it improves structure without changing audible behavior.

Immediately after that, the recommended path is:

1. add score-resource support for short cues
2. expand BGM using the same event-driven system
3. only then open user-authored BGM import

## Non-Goals

This plan does not require:

- an immediate full tracker implementation
- advanced procedural synthesis in the first pass
- shipping user-authored BGM in the first milestone
- redesigning every music asset before the event layer exists

## Success Criteria

This audio upgrade should be considered structurally successful when:

1. gameplay/UI code emits intent, not clip ids
2. mixer policy lives in one place
3. cue and score selection are data-driven or centrally declared
4. adding more BGM does not require threading new playback logic through unrelated layers
5. future sound changes do not require touching unrelated logic layers
6. user-authored BGM can be supported through validated resource loading instead of ad hoc playback hooks
