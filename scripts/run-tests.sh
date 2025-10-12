#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$ROOT_DIR/logs"
mkdir -p "$LOG_DIR"

TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
LOG_FILE="$LOG_DIR/tests-$TIMESTAMP.log"

PROJECT_PATH="$ROOT_DIR/JoystickHIDTest.xcodeproj"
TARGET_NAME="JoystickHIDTest"
CONFIGURATION="${CONFIGURATION:-Debug}"

echo "[tests] Writing log to $LOG_FILE"
echo "[tests] Building target $TARGET_NAME ($CONFIGURATION)"

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
  echo "[tests][error] xcodebuild failed. See $LOG_FILE" >&2
  exit "$BUILD_STATUS"
fi

echo "[tests] Build succeeded. Log stored at $LOG_FILE"
