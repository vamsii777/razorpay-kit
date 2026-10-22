# ADR-0001: Swift 5.10 floor, Swift 6 language mode, and Vapor

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
Use typed throws (`throws(RazorpayError)`) only in Swift 6-only code paths, and only where every
error thrown maps to `RazorpayError`. Public API keeps untyped `throws` so both manifests expose
the same API. Untyped `throws` is the default.

### 3. `~Copyable` and macros
Not used. Neither is needed for an HTTP client SDK, and macros would add a swift-syntax
dependency. Revisit only with a concrete justification in a new ADR.

### 4. Vapor
- **`RazorpayKit` (core) does not depend on Vapor.** It depends only on AsyncHTTPClient/swift-nio
  (and swift-crypto for signatures).
- Vapor stays only in the optional `Razorpay` integration target for beta.1. That keeps PR #5's
  `Application.razorpay` / `Request.razorpay` helpers.
- Follow-up before rc.1: move the Vapor helpers into a separate package or a dedicated
  `RazorpayVapor` target so the core package graph no longer resolves Vapor. If that does not
  land by rc.1, remove the helpers and document the snippet in the migration guide.

## Consequences
- The CI matrix is Swift 5.10, 6.0 and latest (see AGENTS.md).
- Known toolchain issue: on Swift 5.10, `swift-system` 1.6.x (pulled in by swift-nio) declares
  tools 5.9 but fails to parse. 5.10 builds need `swift-system` < 1.6 (verified with 1.5.0, e.g.
  `swift package resolve swift-system --version 1.5.0`) until it is fixed upstream or a version
  constraint is approved.
