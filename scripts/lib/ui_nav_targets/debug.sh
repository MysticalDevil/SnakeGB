#!/usr/bin/env bash

ui_nav_debug_supported_targets() {
  printf '%s\n' \
    "dbg-menu|dbg-play|dbg-pause|dbg-gameover|dbg-replay|dbg-replay-buff|dbg-choice|dbg-catalog|dbg-achievements|dbg-icons|dbg-screen-only|dbg-shell-only"
}

ui_nav_build_debug_target_plan() {
  local target="$1"

  case "${target}" in
    dbg-menu)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_MENU")
      ;;
    dbg-play)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_PLAY")
      ;;
    dbg-pause)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_PAUSE")
      ;;
    dbg-gameover)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_GAMEOVER")
      ;;
    dbg-replay)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_REPLAY")
      ;;
    dbg-replay-buff)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_REPLAY_BUFF")
      ;;
    dbg-choice)
      UI_NAV_TARGET_STEPS+=("TOKEN:$(ui_nav_debug_token DBG_CHOICE "${DBG_CHOICE_TYPES:-}")")
      ;;
    dbg-catalog)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_CATALOG")
      ;;
    dbg-achievements)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_ACHIEVEMENTS")
      ;;
    dbg-icons)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_ICONS")
      ;;
    dbg-screen-only)
      # shellcheck disable=SC2034 # Consumed by caller after this helper returns.
      UI_NAV_TARGET_APP_ARGS="--ui-mode=screen"
      ;;
    dbg-shell-only)
      # shellcheck disable=SC2034 # Consumed by caller after this helper returns.
      UI_NAV_TARGET_APP_ARGS="--ui-mode=shell"
      ;;
    *)
      return 1
      ;;
  esac

  return 0
}
