# SnakeGB - Retro GameBoy Style Snake Game (v1.4.0)

[中文版](README_zh-CN.md)

SnakeGB is a high-quality, cross-platform GameBoy-style Snake game built with **Qt 6** and **C++23**. It faithfully simulates the classic retro handheld experience with modern engineering standards and premium haptic/audio feedback.

## Core Features (v1.4.0)

- **GameBoy Boot Flow**: Boot bounce animation + boot beep + delayed BGM handoff to menu.
- **Expanded Navigation**: Hidden fruit library (`LEFT`), achievements room (`UP`), replay (`DOWN`), level switch (`SELECT`).
- **Refined Input Rules**: Context-sensitive `B` behavior restored across menu/game/pause/game-over/roguelike/library/medal.
- **Dynamic Levels**: `Classic`, `The Cage`, `Dynamic Pulse`, `Tunnel Run`, `Crossfire`, `Shifting Box`.
- **Roguelike Power-up Suite**: 9 distinct effects including working **Magnet** fruit attraction and unique portal wall-phasing.
- **Ghost Replay**: Deterministic replay with recorded input and choice playback.
- **Mobile Sensor Glare**: `QtSensors` accelerometer-powered screen reflection movement (with desktop fallback motion).
- **Android Ready**: arm64 deployment pipeline and runtime logcat-driven crash triage workflow.

## Gameplay

- **Core Loop**: eat food, grow longer, and survive as speed increases.
- **Wrap-Around Board**: crossing screen edges loops snake to the opposite side.
- **Level Variants**:
  - `Classic`: no obstacles.
  - `The Cage`: static wall clusters.
  - `Dynamic Pulse`, `Crossfire`, `Shifting Box`: script-driven moving obstacles.
  - `Tunnel Run`: narrow dual-column tunnel pressure.
- **Roguelike Choices**: random ability choices appear as score progresses; each run can evolve differently.
- **Special Fruits**: 9 fruit effects (Ghost/Slow/Magnet/Shield/Portal/Double/Diamond/Laser/Mini) with temporary or instant buffs.
- **Ghost Replay**: best run input+choice replay for route learning and score improvement.

## Tech Stack

- **Language**: C++23 (std::ranges, std::unique_ptr, Coroutines-ready)
- **Framework**: Qt 6.7+ (Quick, JSEngine, Multimedia, Sensors, ShaderTools)
- **Build System**: CMake + Ninja
- **Optional Wrapper**: `zig build` can drive the existing CMake flow

## Project Layout
- Runtime adapter implementation lives in `src/adapter/` (GameLogic split across focused translation units).

## Getting Started

Release notes live in `CHANGELOG.md`.

### Build and Run (Desktop)
```bash
cmake -S . -B build/debug -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build/debug --parallel
./build/debug/SnakeGB
```

```bash
cmake -S . -B build/release -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/release --parallel
./build/release/SnakeGB
```

- `Debug`: detailed runtime logs enabled.
- `RelWithDebInfo` (`dev`): compact runtime logs enabled.
- `Release` / `MinSizeRel`: routine runtime logs are compiled out.

### Build and Run via Zig
```bash
# Debug -> build/debug
zig build

# Release -> build/release
zig build -Doptimize=ReleaseFast

# Build and run
zig build run

# Configure/build debug tests and run ctest from build/debug
zig build test
```

- `zig build` does not call `cmake`; it drives `moc`, `qsb`, `rcc`, `pkg-config`, and `zig c++` directly.
- Override the output profile directory with `-Dprofile=<name>`.
- `zig build test` builds and runs the Qt test executables directly instead of delegating to `ctest`.

### Build and Deploy (Android)
```bash
# Debug build (logs enabled)
CMAKE_BUILD_TYPE=Debug ./scripts/deploy.sh android

# Release build (logs disabled)
CMAKE_BUILD_TYPE=Release ./scripts/deploy.sh android
```

### Build and Deploy (WebAssembly)
```bash
# Qt WASM toolchain root (example path)
export QT_WASM_PREFIX=~/qt-toolchains/build-qt-wasm/qt-wasm-install-mt

# Build, package to /tmp/snakegb-wasm-dist, and serve locally on :8080
./scripts/deploy.sh wasm
```

- Set `SERVE=0` to only build/package without starting a web server.
- Local serving uses `./scripts/deploy.sh wasm-serve` with COOP/COEP headers so `SharedArrayBuffer` works in Chromium-based browsers.
- `qtlogo.svg`/`favicon` are injected from project icon during packaging to keep wasm console/network logs clean.

## Controls
- **Arrow Keys**: Move snake
- **START (Enter / S)**: Play / Continue from save
- **SELECT (Shift)**: Cycle levels / (Hold) Delete save
- **UP**: Open Medal Collection
- **DOWN**: Watch Best High-Score Replay
- **LEFT**: Open hidden Fruit Library
- **B / X**:
  - In active game (`Playing` / `Roguelike choice`): switch display palette
  - In menu: switch display palette
  - In pause/game over/replay/library/medal: back to menu
- **Y / C / Tap Logo**: Cycle Console Shell Colors
- **M**: Toggle Music
- **Back / Esc**: Quit App

## Input Architecture Notes
- Logging system plan: `docs/LOGGING_SYSTEM_PLAN.md`
- Audio authoring guide: `docs/AUDIO_AUTHORING.md`
- Level authoring guide: `docs/LEVEL_AUTHORING.md`
- Runtime automation injection: set `SNAKEGB_INPUT_FILE=/tmp/snakegb-input.queue` (recommended) or `SNAKEGB_INPUT_PIPE=/tmp/snakegb-input.pipe`, then send tokens with `./scripts/input.sh inject ...`

## License
Licensed under the [GNU GPL v3](LICENSE).
