# Agents Playbook

This document describes the staged plan for instrumenting the repository so engineers, agents, and CI robots can deliver a fully reproducible workflow: local development, automated testing, artifact capture, and deployable build outputs.

## 1. Guiding Principles
- Prefer single-source automation: all workflows should route through a Makefile entry point so contributors can run `make <target>` locally and CI jobs can mirror the same invocation.
- Keep environments immutable: package versions and container images are locked using explicit version pins (Homebrew bundle, Gemfile, npm/yarn lockfiles, Python requirements as needed).
- Ensure observability: every workflow (local, CI, release) must emit structured logs and bundle them into artifacts for traceability.
- Design with air-gap resilience: all automation must run without external secrets by default; optional secret-backed paths should degrade gracefully.

## 2. Local Development Environment
- **Bootstrap**: Provide a `Makefile` target `make bootstrap` that checks for Xcode CLI tools, installs Homebrew, and then runs `brew bundle --no-upgrade` from `Brewfile`. Include taps for required SDKs, `ruby`, `fastlane`, `node`, `yarn`, `python`, `docker`, `kubectl`, `kind`, and `vagrant`.
- **Ruby & Fastlane**: Ship a `.ruby-version` and `Gemfile` (with `fastlane`, `cocoapods`, and testing gems). `make bootstrap` runs `bundle install`.
- **Node Tooling**: If JavaScript tooling is required (docs, packaging, auxiliary scripts), maintain `package.json` + lockfile. Provide `make node-bootstrap` for `npm ci` or `yarn install --frozen-lockfile`.
- **Fastlane lanes**: Define lanes `dev_tests`, `build_app`, `release_candidate`, and `verify_logs`. Each lane shells out to Makefile targets or scripts, ensuring parity with CI.
- **Fastlane lanes**: Define lanes `dev_tests`, `build_app`, `release_candidate`, `visual_tests`, and `verify_logs`. Each lane shells out to Makefile targets or scripts, ensuring parity with CI.
- **Dockerized services**: Use `docker-compose.yml` and `Makefile` target `make compose-up` for integration dependencies (databases, mock services). Provide health checks and `make compose-down`.
- **Vagrant sandbox**: Deliver a `Vagrantfile` that provisions a local Kubernetes cluster (via `kind` or `k3s`), installs `kubectl`, loads container images, and syncs repo. `make vagrant-up` boots the VM; `make vagrant-destroy` tears down.
- **Documentation**: Maintain `docs/local-setup.md` describing prerequisites, bootstrap steps, and troubleshooting. Link from `README.md`.

## 3. Continuous Integration (GitHub Actions)
- **Workflow Layout**: Create `.github/workflows/ci.yml` with composite jobs:
  - `lint` (runs `make lint`).
  - `unit-tests` (runs `make test`).
  - `integration` (spins up Docker services via `make compose-test`).
  - `vagrant-k8s` (uses `macos-latest` or `ubuntu-latest` runner, downloads Vagrant box, boots VM, runs `make k8s-test`).
  - `build-artifacts` (runs `make build` and `fastlane build_app`).
  - `visual-tests` (runs `make visual-tests`, attempting Dockerized macOS image with host fallback).
- **Caching**: Enable caching for `~/.bundle`, `~/.fastlane`, Homebrew bottles, npm cache, and derived data to speed subsequent runs.
- **Secrets**: Keep workflow secrets optional; provide fallback to local certificates or stubbed credentials. Document required secrets in `docs/ci.md`.
- **Matrix Testing**: For multiplatform code, use a matrix across macOS (Xcode versions) and Linux.
- **Artifact Upload**: Each job uploads:
  - `logs/` directory (structured JSON or text logs).
  - Build outputs (`.ipa`, `.xcarchive`, Docker images exported via `docker save`).
  - K8s manifests and test reports (`JUnit`, `xcresult`, `cobertura`).
- **Notifications**: Optionally integrate with GitHub Deployments API or release notes generation using Fastlane plugins.

## 4. Release & Distribution Flow
- **Fastlane Release Lane**: Implement `fastlane release_candidate` that tags the repo, builds production artifacts, runs smoke tests, and pushes to TestFlight or internal distribution.
- **GitHub Releases Pipeline**: Add `.github/workflows/release.yml` triggered on tags or manual dispatch. Steps:
  1. Run the full CI suite as a prerequisite.
  2. Use `fastlane` to compile release notes (`fastlane changelog`).
  3. Upload release assets (binaries, Docker images, manifests, logs).
  4. Publish release notes and mark deployment status.
- **Versioning**: Manage semantic versioning via Fastlane lane that bumps version numbers, updates changelog, and commits changes.

## 5. Artifact Strategy
- Centralize output under `artifacts/<workflow>/<timestamp>/`.
- Emit structured logs via `scripts/collect-logs.sh` invoked from Makefile and Fastlane lanes.
- Ensure Kubernetes tests store:
  - Pod/event logs (`kubectl logs`, `kubectl get events`).
  - Cluster state dumps (`kubectl get all -A -o yaml`).
- Persist macOS visual test logs (`logs/visual/`) and any screenshots captured during runs.
- For Docker builds, push images to a local registry during tests and pack `docker save` tarballs as artifacts.
- Provide a cleanup job (`make artifacts-clean`) to prune old artifacts locally.

## 6. Testing & Verification
- **Unit Tests**: Wrap platform-specific tests (XCTest, Jest, pytest) under `make test`.
- **Integration Tests**: Cover simulated hardware inputs, Vagrant-based Kubernetes deployments, and Dockerized services.
- **End-to-End**: Use Fastlane UI tests or custom scripts for joystick HID scenarios.
- **Log Verification**: Implement `make verify-logs` that parses logs for error patterns and ensures required sections exist. Gate CI success on this target.
- **Reporting**: Convert test outputs to JUnit or HTML reports and upload as artifacts.

## 7. Implementation Roadmap
1. Author automation scaffolding (`Makefile`, `Brewfile`, `Gemfile`, `package.json`, `Fastfile`, `docker-compose.yml`, `Vagrantfile`).
2. Build local bootstrap scripts and document them.
3. Create GitHub Actions workflows; iterate until green on the default branch.
4. Integrate Fastlane lanes with Makefile targets and ensure parity.
5. Add artifact collection scripts and verify they upload correctly in CI.
6. Define release workflow, integrate with GitHub Releases, and document sign-off steps.
7. Continuously refine observability (log formats, dashboards, alerts) as the system scales.

## 8. Ownership & Next Steps
- Assign maintainers for automation assets (`Makefile`, `Fastfile`, CI workflows).
- Schedule regular audits of Vagrant box versions, Docker base images, and dependency locks.
- After initial setup, run a dry-run release (tagged pre-release) to validate end-to-end flows.
- Track follow-up tasks in project management tooling (e.g., GitHub Projects) to ensure incremental improvements.
