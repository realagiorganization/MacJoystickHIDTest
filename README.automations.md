# Automation Surface

This guide summarizes the key automation entry points that keep local development, CI, and release flows in sync.

## Make Targets
- `make install` – Validates Xcode tooling, installs Bundler, and prepares optional gem/npm dependencies without sudo.
- `make sudo_install` – Checks for Vagrant, Docker, `kind`, and Kubernetes CLIs, emitting guidance instead of running privileged commands.
- `make test` – Builds the project in Debug configuration after running the two installers.
- `make visual-tests` – Executes visual validation through Dockerized macOS when possible, falling back to `xcodebuild`/Fastlane on the host.
- `make ci` – Runs install, sudo install, unit build, and visual validation sequentially, recording durations and log sizes.
- `make install_git_hooks` – Connects `.githooks/` to Git's hook path.
- `make clean` – Removes derived data and `logs/`.

## Scripts
- `scripts/install-dev-deps.sh` – Toolchain verification and bundler/npm bootstrap.
- `scripts/install-sudo-deps.sh` – Air-gap friendly checks for privileged tooling.
- `scripts/run-tests.sh` – Deterministic Debug build with x86_64 architectures forced.
- `scripts/visual-tests-core.sh` – Shared Release build logic for visual validation.
- `scripts/run-visual-tests.sh` – Orchestrator that prefers Dockerized macOS and downgrades to host execution.
- `scripts/run-ci.sh` – CI harness that wraps each Make invocation, timestamps, and sizes logs under `logs/ci/<timestamp>/`.
- `scripts/install-git-hooks.sh` – Hook activation utility.

## Fastlane
- `fastlane/Fastfile` defines `visual_tests`, delegating to `scripts/visual-tests-core.sh`. Extend this file with future lanes (`dev_tests`, `release_candidate`, etc.) for comprehensive distribution automation.

## Logs & Artifacts
- Standard logs: `logs/tests-*.log`, `logs/visual/visual-tests-*.log`, and step-specific CI logs under `logs/ci/<timestamp>/`.
- Each CI step reports file size, location, and duration to simplify debugging.
- Add these directories to release artifacts to preserve test evidence and build metadata.
