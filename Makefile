SHELL := /bin/bash

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
LOG_DIR := $(ROOT_DIR)/logs
CONFIGURATION ?= Debug

.PHONY: install sudo_install run-tests test ci install_git_hooks ensure_logs_dir clean help visual-tests

help:
	@echo "Available targets:"
	@echo "  make install           - Install developer dependencies (no sudo)."
	@echo "  make sudo_install      - Validate dependencies that usually need sudo."
	@echo "  make test              - Build project after ensuring dependencies."
	@echo "  make visual-tests      - Execute visual validation tests (Docker or host fallback)."
	@echo "  make ci                - Run CI workflow with structured logs."
	@echo "  make install_git_hooks - Configure local git hooks."
	@echo "  make clean             - Remove build artifacts."

ensure_logs_dir:
	@mkdir -p "$(LOG_DIR)"

install: | ensure_logs_dir
	@./scripts/install-dev-deps.sh

sudo_install: | ensure_logs_dir
	@./scripts/install-sudo-deps.sh

run-tests: | ensure_logs_dir
	@CONFIGURATION="$(CONFIGURATION)" ./scripts/run-tests.sh

test: install sudo_install run-tests
	@echo "[make] Test pipeline completed."

visual-tests: install sudo_install
	@./scripts/run-visual-tests.sh

ci: | ensure_logs_dir
	@CI_MAKE="$(MAKE)" ./scripts/run-ci.sh

install_git_hooks:
	@./scripts/install-git-hooks.sh

clean:
	@echo "[clean] Removing derived data."
	@xcodebuild -project JoystickHIDTest.xcodeproj -target JoystickHIDTest -configuration Debug clean >/dev/null 2>&1 || true
	@rm -rf "$(LOG_DIR)"
