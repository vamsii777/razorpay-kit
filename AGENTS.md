# AGENTS.md — razorpay-kit

Rules for AI-assisted contributions and automated agents. Modeled on [Vapor's AI & Automated Agent Policy](https://github.com/vapor/vapor/blob/main/AGENTS.md). These rules are strict; if a request conflicts with them, stop and ask the maintainer (@vamsii777).

## Policy
- A human authors, submits and owns every PR and must be able to explain it. Fully automated PRs are closed.
- Issues describe real, human-reviewed problems. No bulk or templated bot issues.
- Do not claim, triage or solve `good first issue` tickets with an agent.
- **Security:** report privately via GitHub Security Advisories (see SECURITY.md). Never in a public issue or PR, never automatically.

## Build and test
```
swift build -Xswiftc -warnings-as-errors
swift test
```
Both must pass locally and in CI before a PR is opened. Do not commit `.build/` or `Package.resolved`.

## Hard rules
1. **No network in tests.** Never call the Razorpay API (test or live) from tests, CI or agents. Every test uses the injected mock transport.
2. **No secrets.** Never commit, log, print or paste keys (`rzp_test_…`, `rzp_live_…`), webhook secrets or `.env` files. Use placeholders like `rzp_test_XXXXXXXX`. Types holding secrets redact them in `description`/`debugDescription`/mirrors.
3. **Signatures:** HMAC-SHA256 via swift-crypto with a constant-time compare. Never `==` on signature strings/bytes. Webhooks are verified against the raw body bytes.
4. **Errors:** any non-2xx response throws `RazorpayError` with the HTTP status and Razorpay's error fields. Never return an error payload as success.
5. **Swift 6:** language mode 6, complete strict concurrency, zero warnings. All public types are `Sendable`. No `@unchecked Sendable`, `nonisolated(unsafe)` or `@preconcurrency import` without maintainer approval and a justifying comment.
6. **No force unwraps, `try!`, `print` or `NSLog` in `Sources/`.**
7. **HTTPS only** to `https://api.razorpay.com`; never disable TLS verification.
8. **Dependencies:** only AsyncHTTPClient, swift-nio, swift-crypto, swift-docc-plugin. Anything else needs approval.

## API and SemVer
- Every `public` symbol is API contract and needs DocC with a link to https://razorpay.com/docs/api.
- After 1.0.0, minor releases are additive only. Typed models are added *alongside* existing APIs; nothing is removed or changed incompatibly without a major release. Deprecate for at least one minor before removal.
- Server enums are open (`unknown(String)`); unknown JSON keys are ignored.
- Every PR carries exactly one `semver/*` label (enforced by CI).

## PRs and commits
- One concern per PR, ideally < 400 changed lines excluding fixtures. Link the issue (`Closes #N`).
- Conventional Commits (`feat(payments): …`, `fix(core): …`, `docs: …`). Add user-facing changes to `CHANGELOG.md` under `[Unreleased]`.
- Merge only with green CI, a maintainer approval and a `semver/*` label. Squash-merge to `main`.

## Agents must NOT
- Push to `main`, force-push shared branches, merge PRs, or create/close issues, milestones, tags or releases.
- Weaken or delete tests, or loosen concurrency/lint settings, to make CI pass.
- Bump tools version, platforms or dependencies, or reformat unrelated files, without approval.

## Releasing
- Releases follow milestones. A release `X.Y.Z` is cut **only** when milestone `vX.Y.Z` is closed (all issues done), CI on `main` is green, and the owner (@vamsii777) explicitly approves.
- Only the owner creates the tag and GitHub release. Agents never create tags or releases.
- Checklist: milestone closed → CI green on the release commit → `CHANGELOG.md` section dated → owner approval → owner tags `X.Y.Z` and publishes the release notes from the changelog.
