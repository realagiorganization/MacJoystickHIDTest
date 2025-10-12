#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$ROOT_DIR/.githooks"

if [ ! -d "$HOOKS_DIR" ]; then
  echo "[git-hooks][error] Expected directory $HOOKS_DIR." >&2
  exit 1
fi

find "$HOOKS_DIR" -maxdepth 1 -type f -exec chmod +x {} +

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git config core.hooksPath "$HOOKS_DIR"
  echo "[git-hooks] Git hooks configured to $HOOKS_DIR"
else
  echo "[git-hooks][warn] Not inside a git work tree; skipped git config" >&2
fi
