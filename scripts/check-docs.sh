#!/bin/sh
# Builds DocC for every module and fails on any warning (unresolved links, bad symbol references).
# Usage: scripts/check-docs.sh [module ...]   Needs a toolchain with `docc` (Swift 5.9+). Not run in CI.
set -eu
cd "$(dirname "$0")/.."
out=$(swift package dump-symbol-graph --minimum-access-level public --emit-extension-block-symbols 2>&1)
sg=$(printf "%s\n" "$out" | sed -n "s/^Files written to //p" | tail -1)
[ -d "$sg" ] || { printf "%s\n" "$out" | tail -5; exit 1; }
docc=$(command -v docc || xcrun --find docc)
modules=${*:-$(ls -d Sources/Razorpay* | sed 's|Sources/||')}
status=0
for m in $modules; do
  dir=$(mktemp -d)
  cp "$sg/$m.symbols.json" "$dir/" 2>/dev/null || { echo "== $m: no symbol graph"; status=1; continue; }
  cp "$sg/$m@"*.symbols.json "$dir/" 2>/dev/null || true
  catalog=""
  [ -d "Sources/$m/$m.docc" ] && catalog="Sources/$m/$m.docc"
  out=$("$docc" convert $catalog --additional-symbol-graph-dir "$dir" --fallback-display-name "$m" \
        --fallback-bundle-identifier "com.razorpay-kit.$m" --output-path "$dir/out.doccarchive" 2>&1 || true)
  n=$(printf '%s\n' "$out" | grep -c "warning:" || true)
  echo "== $m: $n warnings"
  [ "$n" = 0 ] || { printf '%s\n' "$out" | grep "warning:" | sort | uniq -c | sort -rn | head -40; status=1; }
  rm -rf "$dir"
done
exit $status
