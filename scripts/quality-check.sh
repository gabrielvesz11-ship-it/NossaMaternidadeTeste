#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

bash -n scripts/*.sh

if command -v swiftlint >/dev/null 2>&1; then
  swiftlint lint --strict --config .swiftlint.yml
else
  echo "warning: swiftlint not installed; skipping local SwiftLint check" >&2
fi

scripts/build-simulator.sh
scripts/build-device-nosign.sh
