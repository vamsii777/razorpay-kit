# Error Handling

The SDK throws one type, ``RazorpayError``, and each case is a different kind of failure:

| Case | When |
| --- | --- |
| ``RazorpayError/api(_:)`` | Razorpay returned non-2xx, or a 2xx with an `error` object |
| ``RazorpayError/decoding(_:)`` | The response was empty, garbled, or missing required fields |
| ``RazorpayError/transport(_:)`` | There was no HTTP response (network, TLS, timeout, cancellation) |
| ``RazorpayError/signatureMismatch(_:)`` | A webhook or Checkout signature did not match |
| ``RazorpayError/invalidRequest(_:)`` | The SDK refused to send the request (for example an empty ID) |

The accessors read naturally:

```swift
do {
    _ = try await razorpay.payments.capture(id, amount: amount)
} catch where error.isInvalidAmount {
    showAmountError(error.apiError?.description)
} catch where error.isRetryable {
    try await retry(sameIdempotencyKey)
} catch {
    logger.error("\(error.statusCode ?? 0) \(error.code?.rawValue ?? "-") \(error.reason ?? "-")")
}
```

With a Swift 6 compiler, `error` in each `catch` is already ``RazorpayError``. With Swift 5.10,
cast it once: `catch let error as RazorpayError`.

``RazorpayError/isRetryable`` is `true` for transport errors (but not cancellation) and for HTTP
408, 409, 429 and 5xx. ``RazorpayError/DecodingFailure`` names the type and JSON path that
failed, and never includes the response body.
