# Webhooks and Checkout

Verify, then decode, in one call.

## Webhooks

Pass the **raw** request body and the `X-Razorpay-Signature` header:

```swift
let event = try razorpay.webhooks.verify(rawBody, signature: headers["X-Razorpay-Signature"]).event
switch event {
case .paymentCaptured(let payment): try await fulfil(payment)
case .orderPaid(let order, let payment): markPaid(order.id, by: payment.id)
case .refundProcessed(let refund): notify(refund.paymentID)
case .unknown(let name, let payload): logger.info("unhandled \(name): \(payload)")
default: break
}
```

- A missing header, a tampered body, a wrong secret, malformed hex or a non-UTF8 body throws
  ``RazorpayError/signatureMismatch(_:)``. Signatures are compared in constant time.
  Surrounding whitespace is trimmed and hex case is ignored.
- A body that verifies but can't be decoded throws ``RazorpayError/decoding(_:)``.
- Don't decode and re-encode the JSON before verifying. Use the exact bytes you received.
- Razorpay may retry deliveries. Use the `X-Razorpay-Event-Id` header to drop duplicates.

## Checkout

Checkout gives your front end `razorpay_payment_id`, `razorpay_order_id` (or
`razorpay_subscription_id`) and `razorpay_signature`. ``CheckoutResponse`` decodes those fields
directly:

```swift
let response = try JSONDecoder().decode(CheckoutResponse.self, from: body)
try razorpay.verify(response)          // throws .signatureMismatch(.payment)
```

Payment Link callbacks work the same way with ``PaymentLinkCallback``.

``RazorpaySignature`` is still available if you want a `Bool` instead of a throw.
