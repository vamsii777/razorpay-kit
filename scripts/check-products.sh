#!/bin/sh
# Builds every library product on its own, in a separate build path, so a module that
# imports something its target doesn't declare fails here instead of only in the umbrella build.
# Usage: scripts/check-products.sh [product ...]   (default: every product in Package.swift)
set -eu
cd "$(dirname "$0")/.."
./scripts/check-manifests.sh
products=${*:-$(sed -n 's/^ *("\(Razorpay[A-Za-z]*\)",.*/\1/p' Package.swift)}
for p in RazorpayCore RazorpayVerification $products; do
  echo "== $p"
  swift build --product "$p" --build-path .build/isolated -Xswiftc -warnings-as-errors
done
