#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_ROOT="$ROOT_DIR/logs/visual"
mkdir -p "$LOG_ROOT"

TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
LOG_FILE="$LOG_ROOT/visual-tests-$TIMESTAMP.log"
CONFIGURATION="${CONFIGURATION:-Release}"

PROJECT_PATH="$ROOT_DIR/JoystickHIDTest.xcodeproj"
TARGET_NAME="${VISUAL_TEST_TARGET:-JoystickHIDTest}"

echo "[visual-tests-core] Logging to $LOG_FILE"
echo "[visual-tests-core] Building $TARGET_NAME ($CONFIGURATION) for visual validation"

BUILD_CMD=(
  xcodebuild
  -project "$PROJECT_PATH"
  -target "$TARGET_NAME"
  -configuration "$CONFIGURATION"
  build
  CODE_SIGN_IDENTITY=""
  CODE_SIGNING_REQUIRED=NO
  ARCHS=x86_64
  VALID_ARCHS=x86_64
  ONLY_ACTIVE_ARCH=YES
)

if command -v xcpretty >/dev/null 2>&1; then
  "${BUILD_CMD[@]}" \
    | tee "$LOG_FILE.raw" \
    | xcpretty \
    | tee "$LOG_FILE"
  BUILD_STATUS=${PIPESTATUS[0]}
  rm -f "$LOG_FILE.raw"
else
  "${BUILD_CMD[@]}" | tee "$LOG_FILE"
  BUILD_STATUS=${PIPESTATUS[0]}
fi

if [ "$BUILD_STATUS" -ne 0 ]; then
  echo "[visual-tests-core][error] Build failed. Inspect $LOG_FILE" >&2
  exit "$BUILD_STATUS"
fi

APP_PATH="$ROOT_DIR/build/$CONFIGURATION/JoystickHIDTest.app"
if [ -d "$APP_PATH" ]; then
  echo "[visual-tests-core] Built app located at $APP_PATH" | tee -a "$LOG_FILE"
else
  echo "[visual-tests-core][warn] Expected app bundle not found at $APP_PATH" | tee -a "$LOG_FILE"
fi

echo "[visual-tests-core] Visual build validation completed." | tee -a "$LOG_FILE"
