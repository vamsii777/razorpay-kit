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
| `RazorpaySignature.verifyWebhook(body:signature:secret:)` → `Bool` | `try client.webhooks.verify(body, signature:)` → ``WebhookEvent`` |
| `RazorpaySignature.verifyPayment(orderID:paymentID:signature:secret:)` | `try client.verify(CheckoutResponse(...))` |
| Endpoints without a typed API | `client.raw.send(.POST, "/v1/…", body: [...])` |

The singular dictionary routes (`client.payment`, `client.order`, …) still work for endpoints
the typed API doesn't cover yet.

## Breaking changes

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
