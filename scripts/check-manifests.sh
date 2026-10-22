#!/bin/sh
# Package.swift (5.10) and Package@swift-6.0.swift must define the same modules and dependencies.
# Only the tools version, StrictConcurrency (implied by Swift 6) and swiftLanguageModes may differ.
set -eu
cd "$(dirname "$0")/.."
norm() { sed -e '1d' -e '/StrictConcurrency/d' -e '/swiftLanguageModes/d' -e 's/,$//' "$1"; }
a=$(mktemp); b=$(mktemp)
trap 'rm -f "$a" "$b"' EXIT
norm Package.swift > "$a"
norm Package@swift-6.0.swift > "$b"
diff -u "$a" "$b" || { echo "Package.swift and Package@swift-6.0.swift differ"; exit 1; }
