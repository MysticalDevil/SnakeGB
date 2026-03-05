#!/usr/bin/env bash
set -euo pipefail

# Purpose: run extreme-map regression suite and enforce anti-loop/timeout gates.
# Inputs:
#   1) build dir (default: build/dev)
#   2) suite file (default: scripts/ci/bot_extreme_suite.tsv)
# Output:
#   row report: cache/ci/nenoserpent_bot_extreme.tsv
#   summary:    cache/ci/nenoserpent_bot_extreme_summary.tsv

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TMP_ROOT="${NENOSERPENT_TMP_DIR:-${NENOSERPENT_CACHE_DIR:-${ROOT_DIR}/cache/ci}}"
mkdir -p "${TMP_ROOT}"
BUILD_DIR="${1:-build/dev}"
SUITE_FILE="${2:-${ROOT_DIR}/scripts/ci/bot_extreme_suite.tsv}"
PROFILE="${BOT_EXTREME_PROFILE:-dev}"
RESULT_FILE="${BOT_EXTREME_RESULT_FILE:-${TMP_ROOT}/nenoserpent_bot_extreme.tsv}"
SUMMARY_FILE="${BOT_EXTREME_SUMMARY_FILE:-${TMP_ROOT}/nenoserpent_bot_extreme_summary.tsv}"
MIN_AVG="${BOT_EXTREME_MIN_AVG:-35}"
MIN_P95="${BOT_EXTREME_MIN_P95:-80}"
MAX_LOOP_RATE="${BOT_EXTREME_MAX_LOOP_RATE:-0.42}"
MAX_TIMEOUT_RATE="${BOT_EXTREME_MAX_TIMEOUT_RATE:-0.35}"
REQUIRE_PASS="${BOT_EXTREME_REQUIRE_PASS:-1}"
GAMES_OVERRIDE="${BOT_EXTREME_GAMES_OVERRIDE:-}"

BIN_PATH="${ROOT_DIR}/${BUILD_DIR}/bot-benchmark"
if [[ ! -x "${BIN_PATH}" ]]; then
  echo "[bot-extreme] missing benchmark binary: ${BIN_PATH}" >&2
  exit 1
fi
if [[ ! -f "${SUITE_FILE}" ]]; then
  echo "[bot-extreme] missing suite file: ${SUITE_FILE}" >&2
  exit 1
fi

printf 'id\tbackend\tmode\tlevel\tseed\tgames\tmax_ticks\tavg\tp95\ttimeout\tloop_rate\ttimeout_rate\tstatus\n' > "${RESULT_FILE}"

while IFS=$'\t' read -r case_id backend mode level seed games max_ticks; do
  if [[ -z "${case_id}" || "${case_id}" == \#* ]]; then
    continue
  fi
  run_games="${games}"
  if [[ -n "${GAMES_OVERRIDE}" ]]; then
    run_games="${GAMES_OVERRIDE}"
  fi

  output="$("${BIN_PATH}" \
    --games "${run_games}" \
    --max-ticks "${max_ticks}" \
    --seed "${seed}" \
    --level "${level}" \
    --profile "${PROFILE}" \
    --mode "${mode}" \
    --backend "${backend}")"

  avg="$(printf '%s\n' "${output}" | rg -o 'score\.avg=[0-9]+(\.[0-9]+)?' | head -n1 | cut -d= -f2)"
  p95="$(printf '%s\n' "${output}" | rg -o 'score\.p95=[0-9]+' | head -n1 | cut -d= -f2)"
  timeout="$(printf '%s\n' "${output}" | rg -o 'outcomes\.timeout=[0-9]+' | head -n1 | cut -d= -f2)"
  loop_rate="$(printf '%s\n' "${output}" | rg -o 'loop\.rate=[0-9]+(\.[0-9]+)?' | head -n1 | cut -d= -f2)"
  if [[ -z "${avg}" || -z "${p95}" || -z "${timeout}" || -z "${loop_rate}" ]]; then
    echo "[bot-extreme] parse failed id=${case_id}" >&2
    exit 1
  fi

  timeout_rate="$(awk -v timeout="${timeout}" -v games="${run_games}" \
    'BEGIN { if (games <= 0) { print "1.000"; exit } printf "%.3f", timeout / games }')"
  status="pass"
  if awk -v avg="${avg}" -v min_avg="${MIN_AVG}" 'BEGIN { exit !(avg < min_avg) }'; then
    status="fail-avg"
  fi
  if (( p95 < MIN_P95 )); then
    if [[ "${status}" == "pass" ]]; then
      status="fail-p95"
    else
      status="${status}+p95"
    fi
  fi
  if awk -v loop="${loop_rate}" -v max="${MAX_LOOP_RATE}" 'BEGIN { exit !(loop > max) }'; then
    if [[ "${status}" == "pass" ]]; then
      status="fail-loop"
    else
      status="${status}+loop"
    fi
  fi
  if awk -v rate="${timeout_rate}" -v max="${MAX_TIMEOUT_RATE}" 'BEGIN { exit !(rate > max) }'; then
    if [[ "${status}" == "pass" ]]; then
      status="fail-timeout-rate"
    else
      status="${status}+timeout-rate"
    fi
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "${case_id}" "${backend}" "${mode}" "${level}" "${seed}" "${run_games}" "${max_ticks}" \
    "${avg}" "${p95}" "${timeout}" "${loop_rate}" "${timeout_rate}" "${status}" >> "${RESULT_FILE}"
done < "${SUITE_FILE}"

printf 'mode\tcases\tavg_mean\tp95_mean\ttimeout_sum\tloop_rate_mean\ttimeout_rate_mean\tfailed_cases\n' > "${SUMMARY_FILE}"
while IFS=$'\t' read -r mode; do
  rows="$(awk -F '\t' -v m="${mode}" 'NR > 1 && $3 == m {print}' "${RESULT_FILE}")"
  if [[ -z "${rows}" ]]; then
    continue
  fi
  cases="$(printf '%s\n' "${rows}" | wc -l | tr -d ' ')"
  avg_mean="$(printf '%s\n' "${rows}" | awk -F '\t' '{sum += $8} END {printf "%.3f", sum / NR}')"
  p95_mean="$(printf '%s\n' "${rows}" | awk -F '\t' '{sum += $9} END {printf "%.3f", sum / NR}')"
  timeout_sum="$(printf '%s\n' "${rows}" | awk -F '\t' '{sum += $10} END {printf "%d", sum}')"
  loop_rate_mean="$(printf '%s\n' "${rows}" | awk -F '\t' '{sum += $11} END {printf "%.3f", sum / NR}')"
  timeout_rate_mean="$(printf '%s\n' "${rows}" | awk -F '\t' '{sum += $12} END {printf "%.3f", sum / NR}')"
  failed_cases="$(printf '%s\n' "${rows}" | awk -F '\t' '$13 != "pass" {count += 1} END {printf "%d", count}')"
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "${mode}" "${cases}" "${avg_mean}" "${p95_mean}" "${timeout_sum}" \
    "${loop_rate_mean}" "${timeout_rate_mean}" "${failed_cases}" >> "${SUMMARY_FILE}"
done < <(awk -F '\t' 'NR > 1 {print $3}' "${RESULT_FILE}" | sort -u)

echo "[bot-extreme] rows: ${RESULT_FILE}"
cat "${RESULT_FILE}"
echo "[bot-extreme] summary: ${SUMMARY_FILE}"
cat "${SUMMARY_FILE}"

if [[ "${REQUIRE_PASS}" == "1" ]]; then
  if awk -F '\t' 'NR > 1 && $13 != "pass" {exit 1}' "${RESULT_FILE}"; then
    echo "[bot-extreme] regression gate passed"
  else
    echo "[bot-extreme] regression gate failed" >&2
    exit 1
  fi
fi
