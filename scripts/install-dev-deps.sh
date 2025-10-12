#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log() {
  printf '[install] %s\n' "$1"
}

warn() {
  printf '[install][warn] %s\n' "$1" >&2
}

fail() {
  printf '[install][error] %s\n' "$1" >&2
  exit 1
}

log "Ensuring required developer tooling is available."

if ! command -v xcodebuild >/dev/null 2>&1; then
  fail "xcodebuild not found. Install Xcode or the Command Line Tools."
fi
log "xcodebuild detected ($(xcodebuild -version | head -n 1))."

if ! command -v xcrun >/dev/null 2>&1; then
  fail "xcrun not found. Verify Command Line Tools installation."
fi

if ! command -v git >/dev/null 2>&1; then
  fail "git not found in PATH."
fi

if command -v brew >/dev/null 2>&1; then
  log "Homebrew detected at $(command -v brew)."
else
  warn "Homebrew not found. Recommended for managing optional tooling."
fi

ensure_gem() {
  local gem_name="$1"
  local binary_name="${2:-$1}"
  local auto_install="${3:-0}"
  if command -v "$binary_name" >/dev/null 2>&1; then
    log "$binary_name already present."
    return 0
  fi
  if [ "$auto_install" -ne 1 ]; then
    warn "$binary_name missing. Install with: gem install $gem_name --user-install"
    return 0
  fi
  if ! command -v gem >/dev/null 2>&1; then
    warn "RubyGems unavailable; skip installing $gem_name."
    return 0
  fi
  log "Installing $gem_name via --user-install."
  if gem install "$gem_name" --user-install >/dev/null 2>&1; then
    log "$gem_name installed. Ensure ~/.gem/*/bin is in PATH."
  else
    warn "Failed to install $gem_name automatically. Install it manually if needed."
  fi
}

ensure_gem "bundler" "bundle" 1
ensure_gem "fastlane" "fastlane" 0
ensure_gem "xcpretty" "xcpretty" 0

if [ -f "$ROOT_DIR/Gemfile" ]; then
  if command -v bundle >/dev/null 2>&1; then
    log "Installing Ruby bundle."
    (
      cd "$ROOT_DIR"
      bundle install --path vendor/bundle
    )
  else
    warn "Gemfile present but bundle command missing."
  fi
fi

if [ -f "$ROOT_DIR/package.json" ]; then
  if command -v npm >/dev/null 2>&1; then
    log "Installing npm dependencies."
    (
      cd "$ROOT_DIR"
      npm install
    )
  else
    warn "package.json present but npm missing."
  fi
fi

mkdir -p "$ROOT_DIR/logs"
log "logs/ directory ready."

log "Developer dependency check complete."
