# ADR-0001: Swift 5.10 floor, Swift 6 language mode, and no Vapor

- Status: Proposed
- Date: 2026-10-22
- Issue: #8 (epic #7)

## Context
PR #5 (`new-api`) used `swift-tools-version:5.8`, enabled the non-existent upcoming feature
`FullTypedThrows`, and adds Vapor as a package dependency. 1.0 must build on Swift 5.10, 6.0 and
latest with `-warnings-as-errors`, with complete strict concurrency.

## Decisions

### 1. Swift 5.10 floor, dual manifest
- `Package.swift` uses `swift-tools-version:5.10`, the minimum supported compiler. It enables
  `StrictConcurrency=complete` and `ExistentialAny` so 5.10 sees the same diagnostics as Swift 6.
- `Package@swift-6.0.swift` (picked automatically by Swift 6.0+) is identical apart from
  `swiftLanguageModes: [.v6]`, so data-race safety is enforced as errors.
- The invalid `FullTypedThrows` flag is dropped.
- Swift 6-only syntax goes behind `#if compiler(>=6.0)` with a 5.10 equivalent alongside.
- All public types conform to `Sendable`. No `@unchecked Sendable`, `nonisolated(unsafe)`, or
  `@preconcurrency import` without maintainer approval and a comment explaining why.

### 2. Typed throws
Public typed APIs declare `throws(RazorpayError)` under `#if compiler(>=6.0)` and plain `throws` in
the `#else` branch, with identical bodies. `scripts/check-typed-throws.sh` keeps the two branches in
sync. Either way, only `RazorpayError` is thrown.

### 3. `~Copyable` and macros
Not used. Neither is needed for an HTTP client SDK, and macros would add a swift-syntax
dependency. Revisit only with a concrete justification in a new ADR.

### 4. Vapor
- **The package does not depend on Vapor.** `RazorpayKit` depends only on AsyncHTTPClient,
  swift-nio and swift-crypto.
- Updated for beta.1 (#49): the optional `Razorpay` integration target, its product and tests
  were removed, together with the Vapor dependency. Vapor apps use `RazorpayKit` directly. The
  DocC article `Vapor.md` and the README show the few lines of storage and webhook-route code.

## Consequences
- The CI matrix is Swift 5.10, 6.0 and latest (see AGENTS.md).
- Known toolchain issue: on Swift 5.10, `swift-system` 1.6.x (pulled in by swift-nio) declares
  tools 5.9 but fails to parse. 5.10 builds need `swift-system` < 1.6 (verified with 1.5.0, e.g.
  `swift package resolve swift-system --version 1.5.0`) until it is fixed upstream or a version
  constraint is approved.
