#!/bin/sh
# Checks that every `#if compiler(>=6.0)` / `#else` pair in Sources differs only by
# `throws(RazorpayError)` versus `throws` (plus `RazorpayError.` qualifiers on 5.10).
set -eu
cd "$(dirname "$0")/.."
status=0
for file in $(grep -rl '#if compiler(>=6.0)' Sources); do
  tmp=$(mktemp -d)
  awk -v dir="$tmp" '
    index($0, "#if compiler(>=6.0)") { mode = "new"; n++; next }
    /^[[:space:]]*#else/ && mode == "new" { mode = "old"; next }
    /^[[:space:]]*#endif/ && mode != "" { mode = ""; next }
    mode == "new" { print > (dir "/" n ".new") }
    mode == "old" { print > (dir "/" n ".old") }
  ' "$file"
  for new in "$tmp"/*.new; do
    [ -e "$new" ] || continue
    old="${new%.new}.old"
    [ -e "$old" ] || continue   # guards without an #else branch are fine
    norm() { sed -e 's/throws(RazorpayError)/throws/g' -e 's/throw RazorpayError\./throw ./g' -e '/^[[:space:]]*\/\/\//d' -e '/^[[:space:]]*\/\//d' -e '/^[[:space:]]*$/d' "$1"; }
    if ! norm "$new" > "$new.n" || ! norm "$old" > "$old.n" || ! diff -u "$old.n" "$new.n" >/dev/null; then
      echo "typed-throws branches differ in $file:"; diff -u "$old.n" "$new.n" || true; status=1
    fi
  done
  rm -rf "$tmp"
done
exit $status
