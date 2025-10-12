# Git Hooks

Repository hooks are shipped in `.githooks/` and activated via `make install_git_hooks`.

## Installation
```bash
make install_git_hooks
```
- Points `core.hooksPath` at `.githooks/`.
- Ensures every hook is executable.

## Pre-Commit Behavior
- Runs `make test` before every commit.
- Aborts the commit when the build fails, prompting you to resolve issues locally.
- Emits logs through the Make target (`logs/tests-*.log`) so you can inspect failures.

## Customizing Hooks
- Add new scripts inside `.githooks/` and re-run `make install_git_hooks` to refresh permissions.
- Hooks use Bash with `set -euo pipefail` for predictable failure handling.
- Avoid referencing absolute paths; rely on repository-relative commands so hooks work across machines.
