#!/usr/bin/env bash

ui_nav_supported_targets() {
  printf '%s\n' \
    "splash|menu|game|pause|pause-back|pause-back-b|pause-resume|achievements|medals|replay|catalog|library|icons|icons-f6|icons-right|konami-on|konami-off|konami-on-paused|konami-off-paused|icons-exit-b|dbg-menu|dbg-play|dbg-pause|dbg-gameover|dbg-replay|dbg-replay-buff|dbg-choice|dbg-catalog|dbg-achievements|dbg-icons|dbg-static-boot|dbg-static-game|dbg-static-replay|dbg-static-choice|dbg-static-off|dbg-screen-only|dbg-shell-only"
}

ui_nav_append_repeated_tokens() {
  local count="$1"
  local token="$2"
  local i=0

  while (( i < count )); do
    UI_NAV_TARGET_STEPS+=("TOKEN:${token}")
    ((i += 1))
  done
}

ui_nav_debug_token() {
  local base_token="$1"
  local injected_params="${2:-}"

  if [[ -n "${injected_params}" ]]; then
    printf '%s:%s' "${base_token}" "${injected_params}"
  else
    printf '%s' "${base_token}"
  fi
}

ui_nav_build_target_plan() {
  local target="$1"
  local nav_retries="${2:-2}"

  # shellcheck disable=SC2034 # Consumed by caller after this helper returns.
  UI_NAV_TARGET_STEPS=()
  # shellcheck disable=SC2034 # Consumed by caller after this helper returns.
  UI_NAV_TARGET_POST_WAIT_OVERRIDE=""
  # shellcheck disable=SC2034 # Consumed by caller after this helper returns.
  UI_NAV_TARGET_APP_ARGS=""

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
    dbg-static-off)
      UI_NAV_TARGET_STEPS+=("TOKEN:DBG_STATIC_OFF")
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
      echo "[error] Unknown target '${target}'. Supported: $(ui_nav_supported_targets)"
      return 3
      ;;
  esac
}
