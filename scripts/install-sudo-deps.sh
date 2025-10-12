#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

log() {
  printf '[sudo-install] %s\n' "$1"
}

warn() {
  printf '[sudo-install][warn] %s\n' "$1" >&2
}

log "Validating tooling that typically needs elevated permissions."

check_or_note() {
  local tool="$1"
  local install_hint="$2"
  if command -v "$tool" >/dev/null 2>&1; then
    log "$tool available at $(command -v "$tool")."
  else
    warn "$tool missing. Install manually: $install_hint"
  fi
}

check_or_note "vagrant" "brew install --cask vagrant"
check_or_note "kubectl" "brew install kubectl"
check_or_note "kind" "brew install kind"
check_or_note "docker" "Install Docker Desktop or run 'brew install --cask docker'"

NFS_DIR="$ROOT_DIR/.vagrant-data"
mkdir -p "$NFS_DIR"
log "Prepared $NFS_DIR for Vagrant shared data."

log "No sudo commands were executed. Review warnings for manual steps."
