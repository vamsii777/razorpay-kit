#!/usr/bin/env bash
# Local/CI build script. Usage: scripts/ci.sh            (build + test)
#                               RUN_TESTS=0 scripts/ci.sh (build only)
# With Docker: SWIFT_IMAGE=swift:5.10 scripts/ci.sh runs inside that container.
# Tests must not touch the network or use real Razorpay keys.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -n "${SWIFT_IMAGE:-}" ]]; then
  exec docker run --rm -e RUN_TESTS="${RUN_TESTS:-1}" -v "$PWD":/src -w /src "$SWIFT_IMAGE" ./scripts/ci.sh
fi

swift --version
swift build --build-tests -Xswiftc -warnings-as-errors
if [[ "${RUN_TESTS:-1}" == "1" ]]; then
  swift test --skip-build ${SWIFT_TEST_ARGS:-}
fi
