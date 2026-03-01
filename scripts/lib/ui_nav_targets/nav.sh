#!/usr/bin/env bash

ui_nav_nav_supported_targets() {
  printf '%s\n' \
    "splash|menu|game|pause|pause-back|pause-back-b|pause-resume|achievements|medals|replay|catalog|library|icons|icons-f6|icons-right|konami-on|konami-off|konami-on-paused|konami-off-paused|icons-exit-b"
}

ui_nav_build_nav_target_plan() {
  local target="$1"
  local nav_retries="${2:-2}"

  case "${target}" in
    splash)
      UI_NAV_TARGET_STEPS+=("SLEEP:${SPLASH_CAPTURE_DELAY:-0.02}")
      # shellcheck disable=SC2034 # Consumed by callers after this helper returns.
      UI_NAV_TARGET_POST_WAIT_OVERRIDE="${SPLASH_POST_WAIT:-0.02}"
      ;;
    menu)
      ;;
    game)
      UI_NAV_TARGET_STEPS+=("TOKEN:START")
      ;;
    pause)
      UI_NAV_TARGET_STEPS+=("TOKEN:START" "SLEEP:0.25" "TOKEN:START")
      ;;
    pause-back)
      UI_NAV_TARGET_STEPS+=("TOKEN:START" "SLEEP:0.25" "TOKEN:START" "SLEEP:0.25" "TOKEN:SELECT")
      ;;
    pause-back-b)
      UI_NAV_TARGET_STEPS+=("TOKEN:START" "SLEEP:0.25" "TOKEN:START" "SLEEP:0.25" "TOKEN:B")
      ;;
    pause-resume)
      UI_NAV_TARGET_STEPS+=("TOKEN:START" "SLEEP:0.25" "TOKEN:START" "SLEEP:0.25" "TOKEN:START")
      ;;
    achievements|medals)
      ui_nav_append_repeated_tokens "${nav_retries}" "UP"
      ;;
    replay)
      ui_nav_append_repeated_tokens "${nav_retries}" "DOWN"
      ;;
    catalog|library)
      ui_nav_append_repeated_tokens "${nav_retries}" "LEFT"
      ;;
    icons)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_ICONS")
      ;;
    icons-f6)
      UI_NAV_TARGET_STEPS+=("TOKEN:F6")
      ;;
    icons-right)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_ICONS" "SLEEP:0.3" "TOKEN:RIGHT")
      ;;
    konami-on)
      UI_NAV_TARGET_STEPS+=("KONAMI")
      ;;
    konami-off)
      UI_NAV_TARGET_STEPS+=("KONAMI" "SLEEP:0.4" "KONAMI")
      ;;
    konami-on-paused)
      UI_NAV_TARGET_STEPS+=("TOKEN:START" "SLEEP:0.25" "TOKEN:START" "SLEEP:0.25" "KONAMI")
      ;;
    konami-off-paused)
      UI_NAV_TARGET_STEPS+=("TOKEN:START" "SLEEP:0.25" "TOKEN:START" "SLEEP:0.25" "KONAMI" "SLEEP:0.4" "KONAMI")
      ;;
    icons-exit-b)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_ICONS" "SLEEP:0.3" "TOKEN:B")
      ;;
    *)
      return 1
      ;;
  esac

  return 0
}
