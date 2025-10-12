#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_ROOT="$ROOT_DIR/logs"

log() {
  printf '[visual-tests] %s\n' "$1"
}

warn() {
  printf '[visual-tests][warn] %s\n' "$1" >&2
}

err() {
  printf '[visual-tests][error] %s\n' "$1" >&2
}

run_host_visual_tests() {
  if [ -f "$ROOT_DIR/fastlane/Fastfile" ]; then
    if command -v bundle >/dev/null 2>&1 && [ -f "$ROOT_DIR/Gemfile" ]; then
      log "Running fastlane visual_tests lane via bundle exec."
      FASTLANE_SKIP_UPDATE_CHECK=1 bundle exec fastlane visual_tests 2>&1 | tee "$LOG_ROOT/fastlane-visual-tests.log"
      local status="${PIPESTATUS[0]}"
      if [ "$status" -eq 0 ]; then
        return 0
      fi
      warn "fastlane visual_tests lane failed (status $status); falling back to xcodebuild."
    elif command -v fastlane >/dev/null 2>&1; then
      log "Running fastlane visual_tests lane via global fastlane."
      FASTLANE_SKIP_UPDATE_CHECK=1 fastlane visual_tests 2>&1 | tee "$LOG_ROOT/fastlane-visual-tests.log"
      local status="${PIPESTATUS[0]}"
      if [ "$status" -eq 0 ]; then
        return 0
      fi
      warn "fastlane visual_tests lane failed (status $status); falling back to xcodebuild."
    else
      warn "fastlane tooling missing; skipping fastlane lane."
    fi
  fi
  log "fastlane lane unavailable; falling back to direct xcodebuild execution."
  CONFIGURATION="${CONFIGURATION:-Release}" "$SCRIPT_DIR/visual-tests-core.sh"
}

should_try_docker() {
  local mode="${VISUAL_TESTS_MODE:-auto}"
  if [ "$mode" = "host" ]; then
    return 1
  fi
  if ! command -v docker >/dev/null 2>&1; then
    return 1
  fi
  if [ "$mode" = "docker" ]; then
    return 0
  fi
  docker image inspect "${MACOS_DOCKER_IMAGE:-sickcodes/docker-osx:ventura}" >/dev/null 2>&1
}

run_docker_visual_tests() {
  local image="${MACOS_DOCKER_IMAGE:-sickcodes/docker-osx:ventura}"
  local container_name="visual-tests-macos"
  log "Attempting containerized visual tests via image $image"
  if ! docker run --rm \
      --name "$container_name" \
      -e "FASTLANE_SKIP_UPDATE_CHECK=1" \
      -e "CI=1" \
      -e "CONFIGURATION=${CONFIGURATION:-Release}" \
      -v "$ROOT_DIR":/workspace \
      -w /workspace \
      "$image" \
      bash -lc "./scripts/visual-tests-core.sh"; then
    warn "Docker-based visual tests failed."
    return 1
  fi
  log "Docker-based visual tests completed successfully."
  return 0
}

mkdir -p "$LOG_ROOT"

if should_try_docker; then
  if run_docker_visual_tests; then
    exit 0
  fi
  warn "Falling back to host execution."
fi

if ! run_host_visual_tests; then
  err "Host visual tests failed."
  exit 1
fi

log "Visual tests completed via host fallback."
