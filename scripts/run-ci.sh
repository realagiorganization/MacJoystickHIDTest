#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_ROOT="$ROOT_DIR/logs"
RUN_STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
CI_DIR="$LOG_ROOT/ci/$RUN_STAMP"
mkdir -p "$CI_DIR"

MAKE_CMD="${CI_MAKE:-make}"

human_size() {
  local bytes="$1"
  python3 - "$bytes" <<'PY'
import sys

size = int(sys.argv[1])
units = ['B', 'KiB', 'MiB', 'GiB', 'TiB']
if size == 0:
    print('0B')
    sys.exit(0)
i = 0
value = float(size)
while value >= 1024 and i < len(units) - 1:
    value /= 1024
    i += 1
print(f"{value:.2f}{units[i]}")
PY
}

run_step() {
  local step_name="$1"
  shift
  local step_log="$CI_DIR/${step_name}.log"
  local start_iso end_iso duration seconds_start seconds_end size_bytes size_human
  start_iso="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  seconds_start="$(date +%s)"
  printf '[ci] [%s] >> %s (log: %s)\n' "$start_iso" "$step_name" "$step_log"
  if ! "$@" > >(tee "$step_log") 2>&1; then
    printf '[ci][error] Step "%s" failed. Review %s\n' "$step_name" "$step_log" >&2
    exit 1
  fi
  seconds_end="$(date +%s)"
  end_iso="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  duration=$((seconds_end - seconds_start))
  size_bytes="$(wc -c <"$step_log" | tr -d ' ')"
  size_human="$(human_size "$size_bytes" 2>/dev/null || echo "${size_bytes}B")"
  printf '[ci] [%s] << %s (duration: %ss, size: %s, path: %s)\n' "$end_iso" "$step_name" "$duration" "$size_human" "$step_log"
}

run_step install "$MAKE_CMD" --no-print-directory install
run_step sudo_install "$MAKE_CMD" --no-print-directory sudo_install
run_step tests "$MAKE_CMD" --no-print-directory run-tests
run_step visual_tests "$MAKE_CMD" --no-print-directory visual-tests

printf '[ci] Logs archived under %s\n' "$CI_DIR"
