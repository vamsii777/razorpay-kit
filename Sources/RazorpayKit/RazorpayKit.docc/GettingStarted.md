# Getting Started

Create a client once and share it. It's a `Sendable` struct, so it's safe to keep in app state.

```swift
let razorpay = RazorpayClient(key: keyID, secret: keySecret, webhookSecret: webhookSecret)
```

The resources are namespaced: ``RazorpayClient/payments``, ``RazorpayClient/orders``,
``RazorpayClient/refunds``, ``RazorpayClient/customers`` and ``RazorpayClient/webhooks``.

```swift
let order = try await razorpay.orders.create(.init(amount: .inr(paise: 50_000), notes: ["cart": "42"]))
let payment = try await razorpay.payments.fetch("pay_TEST000001")
if payment.status == .authorized {
    _ = try await razorpay.payments.capture(payment.id, amount: payment.amount,
                                            options: .init(idempotencyKey: "capture-\(payment.id)"))
}
let refund = try await razorpay.payments.refund(payment.id, .partial(.inr(paise: 10_000)))
```

Amounts are ``Money``, always in minor units (paise). Statuses and methods are open enums: you
can match the known values, and new values Razorpay adds still decode.

### Testing

Pass any ``RazorpayTransport`` to `RazorpayClient(transport:key:secret:)` to return canned
responses. Your tests never need the network.

### Endpoints without a typed API

Use ``RazorpayClient/raw``. It shares authentication, errors and typed throws with the rest of
the SDK:

```swift
let plan = try await razorpay.raw.get("/v1/plans/plan_TEST")
let amount = plan["item"]?["amount"]?.intValue
```
