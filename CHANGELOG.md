# Changelog

## 2.0.0
- Rename product/build/runtime identity from SnakeGB to NenoSerpent across CMake targets, executable name, scripts, CI, and docs.
- Upgrade Android package to `org.devil.nenoserpent` and align Linux desktop entry/icon naming.
- Complete logging system migration to categorized channels under `NenoSerpent.*` with dev/debug/release policy split.

## 1.5.0
- Standardize build output folders to `build/<profile>` and add a Makefile for common build tasks.
- Refresh palette names and tokens, plus static debug scenes for boot/game/replay verification.
- Add desktop entry for Linux packaging.
