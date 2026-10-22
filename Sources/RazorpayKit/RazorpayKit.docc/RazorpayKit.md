# ``RazorpayKit``

A typed, async Swift SDK for the Razorpay API, with built-in webhook and Checkout verification.

## Overview

```swift
import RazorpayKit

let razorpay = RazorpayClient(key: env.keyID, secret: env.keySecret, webhookSecret: env.webhookSecret)

let order = try await razorpay.orders.create(.init(amount: .inr(rupees: 499), receipt: "rcpt_42"))
try razorpay.verify(checkoutResponse)                            // after Checkout
let payment = try await razorpay.payments.capture(checkoutResponse.paymentID, amount: order.amount)
```

Every API is `async`, every model is `Sendable` and `Codable`, IDs are typed, and the only
error you ever see is ``RazorpayError``. On Swift 6 compilers that's enforced with
`throws(RazorpayError)`; Swift 5.10 gets the same behaviour with plain `throws`.

## Topics

### Essentials
- <doc:GettingStarted>
- ``RazorpayClient``
- ``RequestOptions``

### Payments
- ``Payment``
- ``Order``
- ``Refund``
- ``Customer``
- ``Money``
- ``Currency``

### Verification
- <doc:Webhooks>
- ``WebhookEvent``
- ``CheckoutResponse``
- ``PaymentLinkCallback``
- ``RazorpaySignature``

### Lists, errors and escape hatches
- <doc:Pagination>
- <doc:ErrorHandling>
- ``RazorpayList``
- ``RazorpayError``
- ``JSONValue``

### Upgrading
- <doc:Migration>
