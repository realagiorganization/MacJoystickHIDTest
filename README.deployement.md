# Deployment & Visual Test Workflow

This repository now supports repeatable deployment rehearsal and visual validation through Make targets, Fastlane lanes, and optional macOS-in-Docker virtualization.

## Build & Release Surface
- `make build` (via `scripts/visual-tests-core.sh`) builds `JoystickHIDTest.app` in Release configuration for manual packaging or notarization.
- `make visual-tests` orchestrates a Docker-based macOS VM run when the [`sickcodes/docker-osx`](https://github.com/sickcodes/Docker-OSX) image is present, capturing logs under `logs/visual/`.
- Fastlane lane `visual_tests` wraps the same script so CI and manual executions stay identical.
- `make ci` aggregates install, sudo validation, standard tests, and the visual validation stage while collecting timestamped logs beneath `logs/ci/<iso8601>/`.

## Containerized Visual Validation
1. Install Docker Desktop with virtualization support enabled.
2. Fetch a macOS image. The repository defaults to `sickcodes/docker-osx:ventura` but you can point to any compatible build by exporting `MACOS_DOCKER_IMAGE`.
3. Allow the Make target to use Docker:
   ```bash
   VISUAL_TESTS_MODE=docker make visual-tests
   ```
4. The container mounts the repository into `/workspace` and runs `scripts/visual-tests-core.sh`. Logs stay in your host `logs/visual/` directory.
5. If Docker execution fails (image missing, virtualization disabled, etc.), the workflow logs a warning and falls back to host execution.

## Host Fallback (Xcode / Fastlane)
When Docker is unavailable, `make visual-tests` runs the Fastlane lane (if installed through Bundler) or invokes `scripts/visual-tests-core.sh` directly. This path uses `xcodebuild` to produce a Release build suitable for manual UI inspection or screen-record automation.

## Deploying Artifacts
- Generated app bundles live in `build/Release/JoystickHIDTest.app`.
- Use Fastlane (to be extended with `release_candidate` and distribution lanes) to prepare GitHub releases or TestFlight uploads.
- All runs emit structured logs. Upload `logs/visual/` and `logs/ci/<stamp>/` as release artifacts to retain build provenance.

## Verification Checklist
- [ ] `make install` and `make sudo_install` succeed without requiring sudo.
- [ ] `make test` builds Debug binaries.
- [ ] `make visual-tests` runs either Docker or host fallback and stores logs.
- [ ] `make ci` completes and its logs report durations/paths for each phase.
- [ ] Release candidates are generated with Fastlane once the lane is populated.
