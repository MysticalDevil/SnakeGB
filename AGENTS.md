# Repository Guidelines

## Project Structure & Module Organization
- `src/`: C++ game/runtime code (EngineAdapter in `src/adapter/`, FSM in `src/fsm/`, audio/profile/input adapters) and QML UI in `src/qml/`.
- `src/themes/` and `src/levels/`: JSON-driven theme and level data.
- `tests/`: QtTest-based unit/integration tests (`tests/test_engine_adapter.cpp`).
- `scripts/`: developer automation (desktop UI checks, input injection, Android deploy).
- `docs/`: architecture and refactor plans (`ARCHITECTURE_REFACTOR_PLAN.md`).
- `android/`: Android manifest/resources used by Qt Android packaging.

## Build, Test, and Development Commands
- Debug desktop build/run:
```bash
cmake -S . -B build/debug -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build/debug --parallel
./build/debug/SnakeGB
```
- Release build:
```bash
cmake -S . -B build/release -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build/release --parallel
```
- Run tests from an existing build directory:
```bash
cd build/debug && ctest --output-on-failure
```
- Default build directories live under `build/<profile>`.
- Android deploy (Qt + SDK/NDK environment required):
```bash
CMAKE_BUILD_TYPE=Debug ./scripts/android_deploy.sh
```
- Palette screenshot matrix (Wayland, current input semantics):
```bash
./scripts/palette_capture_matrix.sh /tmp/snakegb_palette_matrix
```
- Focused palette capture for menu/game/replay/choice:
```bash
PALETTE_STEPS=0 ./scripts/palette_capture_focus.sh /tmp/snakegb_palette_focus
```
- Release notes live in `CHANGELOG.md`.
- Optional Makefile shortcuts (recommended for consistent build dirs under `build/`):
```bash
make debug
make release
make dev
make test
make tidy
make fmt
make android
make wasm
make clean
```

## Coding Style & Naming Conventions
- C++ standard: C++23 (`CMakeLists.txt`).
- Formatting: `.clang-format` (LLVM base, 4-space indent, 100-column limit). Run `clang-format` before committing.
- Naming: classes/types `PascalCase`, functions/variables `camelCase`, constants/macros `UPPER_SNAKE_CASE`.
- Keep game-state transitions explicit; prefer named enums/states over numeric literals.
- Avoid relative `#include` paths; prefer module-prefixed includes (for example, `core/...`, `adapter/...`, `fsm/...`).
- QML/JS: prefer ES6+ features (`const`/`let`, template strings, arrow functions, destructuring) where supported; avoid legacy `var` unless required by Qt/QML constraints.
- QML layering: keep a single documented stack and preserve it when editing.
  - World, HUD, and screen-space modal UI that should receive the LCD treatment must live inside the shader source tree.
  - If a screen element belongs to the LCD itself, do not place it above the LCD shader just to make it easier to style.
  - Treat `lcdShader` as the last in-screen composition pass: CRT/panel artifacts belong inside its source tree, not above it.
  - Top-level screen `z` ordering must be assigned in `ScreenView.qml` via shared named layer tokens; leaf pages should not hardcode root-level `z` values.
  - Inside a component, `z` is only for local draw order and should use named local properties instead of bare numbers.
  - Debug takeover layers (`IconLab`, `StaticDebug`) must suppress lower-priority overlays/HUD so only one top-level mode owns the screen at a time.
  - `OSDLayer` should remain topmost above CRT/screen treatment layers.
- For ongoing decoupling work, follow `docs/ARCHITECTURE_REFACTOR_PLAN.md` phase checkpoints and acceptance KPIs.

## Testing Guidelines
- Framework: `Qt6::Test` via `engine-adapter-tests` target and `ctest` (`EngineAdapterTest`).
- Add tests in `tests/test_*.cpp`; keep test names descriptive by behavior (for example, `test_portalWrap_keepsHeadInsideBounds`).
- For UI/input regressions, use scripts such as `scripts/ui_self_check.sh` and `scripts/input_semantics_matrix_wayland.sh` when relevant.
- For palette/readability verification, use `scripts/palette_capture_matrix.sh` (captures 5 palette variants for menu/page/icon-lab flows).
- UI capture scripts must be run serially. Do not start `scripts/ui_nav_capture.sh`, `scripts/palette_capture_focus.sh`, `scripts/palette_capture_matrix.sh`, or `scripts/palette_capture_review.sh` in parallel.
- `scripts/ui_nav_capture.sh` owns the global capture lock; if you need multiple captures, queue them in one shell loop or run them one-by-one.
- Shared script helpers live under `scripts/lib/`:
  - `script_common.sh` for generic shell helpers
  - `ui_window_common.sh` for process/window lifecycle
  - `ui_nav_runtime.sh` for runtime-input-file capture/debug flows
  - `capture_batch.sh` for palette wrapper loops and screenshot validation
  - `ui_nav_targets.sh` now declares target plans as explicit step arrays plus optional post-wait overrides; it should not call transport helpers directly.
  - Detailed script structure and maintenance rules live in `docs/SCRIPT_AUTOMATION.md`.
- Current injectable UI debug entry points:
  - `scripts/ui_nav_capture.sh dbg-choice ...` with `DBG_CHOICE_TYPES=7,4,1` to seed choice previews.
  - `scripts/ui_nav_capture.sh dbg-static-{boot,game,replay,choice} ...` with `DBG_STATIC_PARAMS=...` to inject static scene content.
  - `scripts/ui_nav_debug.sh <target>` uses the same target router for manual inspection and accepts the same `DBG_CHOICE_TYPES` / `DBG_STATIC_PARAMS` env vars.
  - Manual token injection goes through the runtime input file, for example `printf 'DBG_STATIC_CHOICE:TITLE=POWER_PICK,CHOICES=7|4|1,INDEX=1\n' >> /tmp/snakegb_ui_input.txt`.
  - Detailed parameter formats and supported scenes live in `docs/UI_DEBUG_INJECTION.md`.
- Enforce this validation order for C++ changes: `clang-tidy` first, then build, then tests.
- Run `clang-tidy` on touched C++ files before each commit (use `-p <build-dir>` and prefer fixing new warnings in the same change).
- Prefer `scripts/clang_tidy_cached.sh <build-dir> [files...]` to avoid re-running `clang-tidy` on unchanged files.
- Build uses `ccache` automatically when available (`SNAKEGB_USE_CCACHE=ON` in CMake).

## Commit & Pull Request Guidelines
- Follow Conventional Commit style seen in history: `feat(ui): ...`, `fix(runtime+ui): ...`, `refactor(input): ...`, `docs(arch): ...`.
- Keep commits scoped and buildable; include tests/docs updates with behavior changes.
- PRs should include: concise problem/solution summary, linked issue (if any), test evidence (`ctest` output), and screenshots/GIFs for QML UI changes.
- Ensure CI (`.github/workflows/cmake.yml`) is green before merge.
