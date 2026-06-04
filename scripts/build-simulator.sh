#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${PROJECT_PATH:-ios/NossaMaternidade.xcodeproj}"
SCHEME="${SCHEME:-NossaMaternidade}"
CONFIGURATION="${CONFIGURATION:-Debug}"
DERIVED_DATA="${DERIVED_DATA:-.build/DerivedData}"

if [[ -n "${DESTINATION:-}" ]]; then
  XCODE_DESTINATION="$DESTINATION"
elif [[ -n "${SIMULATOR_ID:-}" ]]; then
  XCODE_DESTINATION="platform=iOS Simulator,id=$SIMULATOR_ID"
elif [[ -n "${SIMULATOR_NAME:-}" ]]; then
  XCODE_DESTINATION="platform=iOS Simulator,name=$SIMULATOR_NAME,OS=latest"
else
  XCODE_DESTINATION="generic/platform=iOS Simulator"
fi

xcodebuild build \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "$XCODE_DESTINATION" \
  -derivedDataPath "$DERIVED_DATA"
