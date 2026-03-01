#!/usr/bin/env bash

ui_nav_static_supported_targets() {
  printf '%s\n' \
    "dbg-static-boot|dbg-static-game|dbg-static-replay|dbg-static-choice|dbg-static-osd|dbg-static-vol|dbg-static-off"
}

ui_nav_build_static_target_plan() {
  local target="$1"

  case "${target}" in
    dbg-static-boot)
      UI_NAV_TARGET_STEPS+=("TOKEN:$(ui_nav_debug_token DBG_STATIC_BOOT "${DBG_STATIC_PARAMS:-}")")
      ;;
    dbg-static-game)
      UI_NAV_TARGET_STEPS+=("TOKEN:$(ui_nav_debug_token DBG_STATIC_GAME "${DBG_STATIC_PARAMS:-}")")
      ;;
    dbg-static-replay)
      UI_NAV_TARGET_STEPS+=("TOKEN:$(ui_nav_debug_token DBG_STATIC_REPLAY "${DBG_STATIC_PARAMS:-}")")
      ;;
    dbg-static-choice)
      UI_NAV_TARGET_STEPS+=("TOKEN:$(ui_nav_debug_token DBG_STATIC_CHOICE "${DBG_STATIC_PARAMS:-}")")
      ;;
    dbg-static-osd)
      UI_NAV_TARGET_STEPS+=("TOKEN:$(ui_nav_debug_token DBG_STATIC_OSD "${DBG_STATIC_PARAMS:-}")")
      ;;
    dbg-static-vol)
      UI_NAV_TARGET_STEPS+=("TOKEN:$(ui_nav_debug_token DBG_STATIC_VOL "${DBG_STATIC_PARAMS:-}")")
      ;;
    dbg-static-off)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_STATIC_OFF")
      ;;
    *)
      return 1
      ;;
  esac

  return 0
}
