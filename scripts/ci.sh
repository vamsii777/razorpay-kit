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

./scripts/check-typed-throws.sh
./scripts/check-manifests.sh
# Every product must build on its own (also re-checks manifest parity).
# Only the newest toolchain runs it by default (the 5.10 and 6.0 CI legs skip it for speed).
if swift --version 2>&1 | grep -Eq "Swift version (5\.10|6\.0)(\.|[^0-9])"; then default_products=0; else default_products=1; fi
CHECK_PRODUCTS="${CHECK_PRODUCTS:-$default_products}"
swift --version
# Swift 5.10: newer swift-system releases need a newer compiler; pin to 1.5.0.
if swift --version 2>&1 | grep -q 'Swift version 5\.10'; then
  swift package resolve
  swift package resolve swift-system --version 1.5.0
fi
if [[ "${RUN_TESTS:-1}" == "1" ]]; then
  swift build --build-tests -Xswiftc -warnings-as-errors
  swift test --skip-build --parallel ${SWIFT_TEST_ARGS:-}
else
  # Build-only (e.g. Swift 5.10, which has no swift-testing): skip test targets.
  swift build -Xswiftc -warnings-as-errors
fi
if [[ "$CHECK_PRODUCTS" == "1" ]]; then
  ./scripts/check-products.sh
fi
