# Migrating to 1.0

1.0 adds a typed API next to the dictionary routes and reshapes the error type.

## Calls

| 0.x | 1.0 |
| --- | --- |
| `client.order.create(data: ["amount": 50000, "currency": "INR"], extraHeaders: nil)` | `client.orders.create(.init(amount: .inr(paise: 50_000)))` |
| `client.payment.fetch(paymentID: id, queryParams: nil, extraHeaders: nil)["status"] as? String` | `client.payments.fetch(id).status` |
| `client.payment.capture(paymentID: id, amount: 500, currency: .indianRupee)` | `client.payments.capture(id, amount: .inr(paise: 500))` |
| `client.payment.refund(paymentID: id, amount: 100, data: [:])` | `client.payments.refund(id, .partial(.inr(paise: 100)))` |
| `client.order.all(queryParams: ["count": "100", "skip": "…"])` loops | `for try await o in client.orders.list()` |
| `extraHeaders: ["X-Razorpay-Account": acc]` | `options: .init(accountID: acc)` |
| `RazorpaySignature.verifyWebhook(body:signature:secret:)` → `Bool` | `try client.webhooks.verify(body, signature:)` → ``RazorpayWebhook`` (`.event` → ``WebhookEvent``) |
| `RazorpaySignature.verifyPayment(orderID:paymentID:signature:secret:)` | `try client.verify(CheckoutResponse(...))` |
| `client.payment.fetchPaymentDowntime()` (deprecated) | `try await client.payments.downtimes()` → `[Downtime]` |
| `client.payment.fetchPaymentDowntimeById(downtimeId: id)` (deprecated) | `try await client.payments.downtime(id)` |
| `client.payment.validateVpa(data: ["vpa": v])` | `try await client.payments.validateVPA(v)` |
| `client.payment.fetchCardDetails(paymentID: id)` | `try await client.payments.card(of: id)` |
| `client.payment.fetchMethods()` | `try await client.payments.methods()` |
| `client.payment.createPaymentJson(data:)` / `createRecurringPayment(data:)` | `payments.create(PaymentRequest(...))` / `payments.createRecurring(...)` |
| `client.payment.otpGenerate/otpSubmit/otpResend` | `payments.generateOTP(for:)`, `submitOTP(_:for:)`, `resendOTP(for:)` |
| Endpoints without a typed API | `client.raw.send(.POST, "/v1/…", body: [...])` |

The singular dictionary routes (`client.payment`, `client.order`, …) still compile but are deprecated
wherever a typed module covers the area; `client.raw` reaches any endpoint without a typed API.

## Breaking changes

- The Vapor `Razorpay` product and target are gone, and so is the Vapor dependency. Use `RazorpayKit` directly. <doc:Vapor> shows the few lines that replace `Application.razorpay` and `Request.razorpay`.
- `RazorpayClient` is a `Sendable` struct instead of an actor. Drop any `await` that was only
  there to reach a property.
- ``RazorpayError``:
  - `.apiError` is now `.api`.
  - `.invalidResponse` is now `.decoding`.
  - New cases: `.transport`, `.signatureMismatch` and `.invalidRequest`.
  - `isMissingRequiredField` and `isValidPaymentId` are replaced by `isValidationFailure`.
  - Network errors arrive as `.transport(underlying)` instead of the raw error.
- ``Currency`` is an open struct, so `switch` needs a `default`. `description` is now `displayName`.
  `convertToSmallestUnit` rounds half-up instead of truncating.
- `extraHeaders` can no longer override `Authorization`, and no longer duplicates `Content-Type`.

## beta.1 → beta.2: modular packages

`RazorpayKit` is now an umbrella over `RazorpayCore`, `RazorpayVerification`, `RazorpayPayments`,
`RazorpayOrders`, `RazorpayRefunds`, `RazorpayCustomers` and `RazorpayLegacy`. `import RazorpayKit`
keeps working unchanged; depend on a single product (for example `RazorpayPayments`) for a smaller build.

`webhooks.verify(_:signature:)` now returns the generic ``RazorpayWebhook`` envelope so every module can
decode its own entity. Append `.event` to get the ``WebhookEvent`` enum you used in beta.1.

### New typed areas in beta.2

| Dictionary route | Typed API |
| --- | --- |
| `client.token.all(customerID:)` / `fetch` / `delete` | `client.tokens.list(for:)` / `fetch(_:for:)` / `delete(_:for:)` |
| `client.card.fetch(cardID:)` / `requestCardReference` | `client.cards.fetch(_:)` / `reference(.number(…))` |
| `client.paymentLink.create(data:)` … | `client.paymentLinks.create(.init(amount: …))`, `fetch`, `list`, `update`, `cancel`, `notify` |
| `client.qrCode.create(data:)` … | `client.qrCodes.create(.init(usage: …))`, `fetch`, `list`, `payments(of:)`, `close` |
| `client.payment.transfer` / `client.transfer.*` | `client.transfers.create(from:_:)`, `create`, `fetch`, `list`, `hold`, `reverse`, `reversals(of:)` |
| `client.stakeholder.*` | `client.linkedAccounts.addStakeholder(to:_:)`, `stakeholder(_:of:)`, `stakeholders(of:)`, `updateStakeholder` |
| `client.virtualAccount.*` / `client.payment.bankTransfer` | `client.virtualAccounts.*`, `virtualAccounts.bankTransfer(for:)` |
| `client.fundAccount.*` | `client.fundAccounts.create(for:_:)`, `list(for:)` |
| — | `client.customers.addBankAccount(_:to:)`, `deleteBankAccount(_:of:)` |
