#!/usr/bin/env bash
set -euo pipefail

case_menu_b_non_exit() {
  send_key "X"
  expect_alive "case_menu_b_non_exit"
  send_key "Escape"
  expect_exit "case_menu_b_non_exit/cleanup"
}

case_menu_escape_exits() {
  send_key "Escape"
  expect_exit "case_menu_escape_exits"
}

case_menu_select_non_exit() {
  send_key "Shift_L"
  expect_alive "case_menu_select_non_exit"
  send_key "Escape"
  expect_exit "case_menu_select_non_exit/cleanup"
}

case_play_pause_b_non_exit_then_select_menu_then_exit() {
  send_key "Return"
  send_key "Return"
  send_key "X"
  expect_alive "case_play_pause_b_non_exit_then_select_menu_then_exit"
  send_key "Shift_L"
  expect_alive "case_play_pause_b_non_exit_then_select_menu_then_exit"
  send_key "Escape"
  expect_exit "case_play_pause_b_non_exit_then_select_menu_then_exit/cleanup"
}

case_icon_lab_f6_b_exit_no_crash() {
  send_key "F6"
  send_key "X"
  expect_alive "case_icon_lab_f6_b_exit_no_crash"
  send_key "Escape"
  expect_exit "case_icon_lab_f6_b_exit_no_crash/cleanup"
}

case_konami_sequence_no_crash() {
  send_key "Return"
  send_key "Return"
  send_konami
  expect_alive "case_konami_sequence_no_crash"
  send_key "Escape"
  expect_alive "case_konami_sequence_no_crash"
  send_key "Escape"
  expect_exit "case_konami_sequence_no_crash/cleanup"
}

run_input_semantics_cases() {
  run_case "menu_b_non_exit" case_menu_b_non_exit
  run_case "menu_escape_exits" case_menu_escape_exits
  run_case "menu_select_non_exit" case_menu_select_non_exit
  run_case "play_pause_b_non_exit_then_select_menu_then_exit" case_play_pause_b_non_exit_then_select_menu_then_exit
  run_case "icon_lab_f6_b_exit_no_crash" case_icon_lab_f6_b_exit_no_crash
  run_case "konami_sequence_no_crash" case_konami_sequence_no_crash
}
