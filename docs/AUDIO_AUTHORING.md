# Audio Authoring Guide

This document defines the current authoring contract for SnakeGB audio content.

It covers:

- built-in cue and BGM score resources
- supported note and duty values
- custom BGM override files

For architecture and roadmap, see [AUDIO_SYSTEM_PLAN.md](/home/omega/ai-workspace/gameboy-snack/docs/AUDIO_SYSTEM_PLAN.md).

## File Locations

Built-in audio score resources live in:

- [src/audio/score_catalog.json](/home/omega/ai-workspace/gameboy-snack/src/audio/score_catalog.json)

Runtime loading is implemented in:

- [src/audio/score.cpp](/home/omega/ai-workspace/gameboy-snack/src/audio/score.cpp)

Audio routing and playback policy live in:

- [src/services/audio/bus.cpp](/home/omega/ai-workspace/gameboy-snack/src/services/audio/bus.cpp)
- [src/sound_manager.cpp](/home/omega/ai-workspace/gameboy-snack/src/sound_manager.cpp)

## Resource Shape

The score catalog is a single JSON object with two top-level sections:

```json
{
  "cues": {},
  "tracks": {}
}
```

## Cue Format

Short one-shot cues live under `cues`.

Currently supported built-in cue ids:

- `ui_interact`
- `confirm`

Each cue is an array of steps:

```json
"ui_interact": [
  { "frequencyHz": 262, "durationMs": 22, "duty": 0.5, "amplitude": 18 },
  { "frequencyHz": 330, "durationMs": 28, "duty": 0.5, "amplitude": 18 }
]
```

Supported fields:

- `frequencyHz`: integer frequency in Hz
- `durationMs`: integer duration in milliseconds
- `duty`: pulse duty as a float
- `amplitude`: integer amplitude

Notes:

- Cue steps currently use raw frequency values, not note names.
- This is intentional for now; cue rendering still accepts compact beep-style data.
- Missing or invalid cue arrays fall back to an empty cue and simply produce no score cue output.

## Track Format

Looped BGM tracks live under `tracks`.

Currently supported built-in track ids:

- `menu`
- `menu_alt`
- `gameplay`
- `gameplay_alt`
- `replay`
- `replay_alt`

Each track is an array of steps:

```json
"menu": [
  {
    "lead": "E5",
    "bass": "C3",
    "durationMs": 180,
    "leadDuty": "quarter",
    "bassDuty": "half"
  }
]
```

Supported fields:

- `lead`: note name for the lead voice
- `bass`: note name for the bass voice
- `durationMs`: integer step duration in milliseconds
- `leadDuty`: pulse duty name
- `bassDuty`: pulse duty name

## Supported Notes

The parser currently supports this exact note set:

- `REST`
- `C3`, `D3`, `E3`, `F3`, `G3`, `A3`, `B3`
- `C4`, `D4`, `E4`, `F4`, `G4`, `A4`, `B4`
- `C5`, `D5`, `E5`, `F5`, `G5`, `A5`

Anything outside this set currently resolves to `REST`.

If you need a wider range, extend [Pitch](/home/omega/ai-workspace/gameboy-snack/src/audio/score.h) and
[pitchFromName(...)](/home/omega/ai-workspace/gameboy-snack/src/audio/score.cpp).

## Supported Duty Names

Track duty strings must be one of:

- `narrow`
- `quarter`
- `half`
- `wide`

They currently map to:

- `narrow` -> `12.5%`
- `quarter` -> `25%`
- `half` -> `50%`
- `wide` -> `75%`

Unknown duty strings fall back to:

- lead: `quarter`
- bass: `half`

## Custom BGM Override File

The runtime supports a controlled external override file for BGM tracks.

Default location:

- `QStandardPaths::AppDataLocation/audio/custom_tracks.json`

Override path for testing/manual iteration:

- env var `SNAKEGB_SCORE_OVERRIDE_FILE`

Example:

```bash
SNAKEGB_SCORE_OVERRIDE_FILE=/tmp/custom_tracks.json ./build/dev/SnakeGB
```

Override file shape:

```json
{
  "tracks": {
    "menu": [
      {
        "lead": "A5",
        "bass": "A3",
        "durationMs": 180,
        "leadDuty": "wide",
        "bassDuty": "quarter"
      }
    ],
    "menu_alt": [],
    "gameplay": [],
    "gameplay_alt": [],
    "replay": [],
    "replay_alt": []
  }
}
```

Rules:

- `tracks.menu`, `tracks.menu_alt`, `tracks.gameplay`, `tracks.gameplay_alt`,
  `tracks.replay`, and `tracks.replay_alt` are supported.
- Overrides are per-track.
- If an override track parses to a non-empty step list, it replaces the built-in track.
- Invalid, missing, or empty override tracks fall back to the built-in resource track.
- There is currently no custom cue override path.

## Authoring Guidelines

- Keep `durationMs` values aligned to a small rhythmic grid.
- Prefer `REST` over fake silent notes.
- Use `quarter` or `half` for most GB-like lines; only use `wide` sparingly.
- Keep bass simpler than lead; the runtime is still a minimal two-voice synth.
- Test menu/gameplay/replay tracks individually after edits.

## Validation Workflow

For score changes:

```bash
clang-format -i src/audio/score.cpp tests/test_audio_bus_service.cpp
./scripts/dev.sh clang-tidy build/dev src/audio/score.cpp tests/test_audio_bus_service.cpp src/services/audio/bus.cpp src/sound_manager.cpp
cmake --build build/dev --parallel
cd build/dev && ctest --output-on-failure
```

Useful manual checks:

```bash
./build/dev/SnakeGB
SNAKEGB_SCORE_OVERRIDE_FILE=/tmp/custom_tracks.json ./build/dev/SnakeGB
```

## Current Limits

- Cue resources still use raw `frequencyHz` rather than note names.
- Built-in music currently exposes two variants per runtime slot (`A/B`) rather than arbitrary sets.
- No end-user import UI exists yet.
- No metadata such as tempo, loop markers, gain, or per-track bus assignment exists yet.
