# Repository Guidelines

## Project Structure & Module Organization
- `src/`: C++ game/runtime code (`game_logic.*`, FSM in `src/fsm/`, audio/profile/input adapters) and QML UI in `src/qml/`.
- `src/themes/` and `src/levels/`: JSON-driven theme and level data.
- `tests/`: QtTest-based unit/integration tests (`tests/test_game_logic.cpp`).
- `scripts/`: developer automation (desktop UI checks, input injection, Android deploy).
- `docs/`: architecture and refactor plans (`ARCHITECTURE_REFACTOR_PLAN.md`).
- `android/`: Android manifest/resources used by Qt Android packaging.

## Build, Test, and Development Commands
- Debug desktop build/run:
```bash
cmake -S . -B build-debug -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build-debug --parallel
./build-debug/SnakeGB
```
- Release build:
```bash
cmake -S . -B build-release -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build-release --parallel
```
- Run tests from an existing build directory:
```bash
cd build-debug && ctest --output-on-failure
```
- Android deploy (Qt + SDK/NDK environment required):
```bash
CMAKE_BUILD_TYPE=Debug ./scripts/android_deploy.sh
```

## Coding Style & Naming Conventions
- C++ standard: C++23 (`CMakeLists.txt`).
- Formatting: `.clang-format` (LLVM base, 4-space indent, 100-column limit). Run `clang-format` before committing.
- Naming: classes/types `PascalCase`, functions/variables `camelCase`, constants/macros `UPPER_SNAKE_CASE`.
- Keep game-state transitions explicit; prefer named enums/states over numeric literals.
- For ongoing decoupling work, follow `docs/ARCHITECTURE_REFACTOR_PLAN.md` phase checkpoints and acceptance KPIs.

## Testing Guidelines
- Framework: `Qt6::Test` via `game-tests` target and `ctest` (`GameLogicTest`).
- Add tests in `tests/test_*.cpp`; keep test names descriptive by behavior (for example, `test_portalWrap_keepsHeadInsideBounds`).
- For UI/input regressions, use scripts such as `scripts/ui_self_check.sh` and `scripts/input_semantics_matrix_wayland.sh` when relevant.
- Run `clang-tidy` on touched C++ files before each commit (use `-p <build-dir>` and prefer fixing new warnings in the same change).

## Commit & Pull Request Guidelines
- Follow Conventional Commit style seen in history: `feat(ui): ...`, `fix(runtime+ui): ...`, `refactor(input): ...`, `docs(arch): ...`.
- Keep commits scoped and buildable; include tests/docs updates with behavior changes.
- PRs should include: concise problem/solution summary, linked issue (if any), test evidence (`ctest` output), and screenshots/GIFs for QML UI changes.
- Ensure CI (`.github/workflows/cmake.yml`) is green before merge.
