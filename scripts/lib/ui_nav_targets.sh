#!/usr/bin/env bash

ui_nav_supported_targets() {
  printf '%s\n' \
    "splash|menu|game|pause|pause-back|pause-back-b|pause-resume|achievements|medals|replay|catalog|library|icons|icons-f6|icons-right|konami-on|konami-off|konami-on-paused|konami-off-paused|icons-exit-b|dbg-menu|dbg-play|dbg-pause|dbg-gameover|dbg-replay|dbg-replay-buff|dbg-choice|dbg-catalog|dbg-achievements|dbg-icons|dbg-static-boot|dbg-static-game|dbg-static-replay|dbg-static-choice|dbg-static-off"
}

ui_nav_apply_target() {
  local target="$1"

  case "${target}" in
    splash)
      # Capture/debug splash shortly after launch before transition to start menu.
      sleep "${SPLASH_CAPTURE_DELAY:-0.02}"
      # shellcheck disable=SC2034  # Consumed by the caller after this sourced helper returns.
      POST_NAV_WAIT="${SPLASH_POST_WAIT:-0.02}"
      ;;
    menu)
      ;;
    game)
      send_token "START"
      ;;
    pause)
      send_token "START"
      sleep 0.25
      send_token "START"
      ;;
    pause-back)
      send_token "START"
      sleep 0.25
      send_token "START"
      sleep 0.25
      send_token "SELECT"
      ;;
    pause-back-b)
      send_token "START"
      sleep 0.25
      send_token "START"
      sleep 0.25
      send_token "B"
      ;;
    pause-resume)
      send_token "START"
      sleep 0.25
      send_token "START"
      sleep 0.25
      send_token "START"
      ;;
    achievements|medals)
      local i=0
      while (( i < NAV_RETRIES )); do
        send_token "UP"
        ((i += 1))
      done
      ;;
    replay)
      local i=0
      while (( i < NAV_RETRIES )); do
        send_token "DOWN"
        ((i += 1))
      done
      ;;
    catalog|library)
      local i=0
      while (( i < NAV_RETRIES )); do
        send_token "LEFT"
        ((i += 1))
      done
      ;;
    icons)
      send_token "DBG_ICONS"
      ;;
    icons-f6)
      send_token "F6"
      ;;
    icons-right)
      send_token "DBG_ICONS"
      sleep 0.3
      send_token "RIGHT"
      ;;
    konami-on)
      send_konami
      ;;
    konami-off)
      send_konami
      sleep 0.4
      send_konami
      ;;
    konami-on-paused)
      send_token "START"
      sleep 0.25
      send_token "START"
      sleep 0.25
      send_konami
      ;;
    konami-off-paused)
      send_token "START"
      sleep 0.25
      send_token "START"
      sleep 0.25
      send_konami
      sleep 0.4
      send_konami
      ;;
    icons-exit-b)
      send_token "DBG_ICONS"
      sleep 0.3
      send_token "B"
      ;;
    dbg-menu)
      send_token "DBG_MENU"
      ;;
    dbg-play)
      send_token "DBG_PLAY"
      ;;
    dbg-pause)
      send_token "DBG_PAUSE"
      ;;
    dbg-gameover)
      send_token "DBG_GAMEOVER"
      ;;
    dbg-replay)
      send_token "DBG_REPLAY"
      ;;
    dbg-replay-buff)
      send_token "DBG_REPLAY_BUFF"
      ;;
    dbg-choice)
      if [[ -n "${DBG_CHOICE_TYPES:-}" ]]; then
        send_token "DBG_CHOICE:${DBG_CHOICE_TYPES}"
      else
        send_token "DBG_CHOICE"
      fi
      ;;
    dbg-catalog)
      send_token "DBG_CATALOG"
      ;;
    dbg-achievements)
      send_token "DBG_ACHIEVEMENTS"
      ;;
    dbg-icons)
      send_token "DBG_ICONS"
      ;;
    dbg-static-boot)
      if [[ -n "${DBG_STATIC_PARAMS:-}" ]]; then
        send_token "DBG_STATIC_BOOT:${DBG_STATIC_PARAMS}"
      else
        send_token "DBG_STATIC_BOOT"
      fi
      ;;
    dbg-static-game)
      if [[ -n "${DBG_STATIC_PARAMS:-}" ]]; then
        send_token "DBG_STATIC_GAME:${DBG_STATIC_PARAMS}"
      else
        send_token "DBG_STATIC_GAME"
      fi
      ;;
    dbg-static-replay)
      if [[ -n "${DBG_STATIC_PARAMS:-}" ]]; then
        send_token "DBG_STATIC_REPLAY:${DBG_STATIC_PARAMS}"
      else
        send_token "DBG_STATIC_REPLAY"
      fi
      ;;
    dbg-static-choice)
      if [[ -n "${DBG_STATIC_PARAMS:-}" ]]; then
        send_token "DBG_STATIC_CHOICE:${DBG_STATIC_PARAMS}"
      else
        send_token "DBG_STATIC_CHOICE"
      fi
      ;;
    dbg-static-off)
      send_token "DBG_STATIC_OFF"
      ;;
    *)
      echo "[error] Unknown target '${target}'. Supported: $(ui_nav_supported_targets)"
      return 3
      ;;
  esac
}
