# Choosing modules

Depend on `RazorpayKit` for everything, or on just the areas you call.

## Overview

Every Razorpay API area is its own library product. Each one adds a namespace to the same
``RazorpayClient``, so code looks the same whichever products you pick:

```swift
// Package.swift
.product(name: "RazorpayOrders", package: "razorpay-kit"),
.product(name: "RazorpayVerification", package: "razorpay-kit"),

// App
import RazorpayCore
import RazorpayOrders
import RazorpayVerification

let order = try await razorpay.orders.create(.init(amount: .inr(rupees: 499)))
```

`import RazorpayKit` re-exports every module and adds the exhaustive ``WebhookEvent`` enum.

| Product | Namespaces | Depends on |
| --- | --- | --- |
| `RazorpayCore` | `raw`, shared types | AsyncHTTPClient, SwiftNIO |
| `RazorpayVerification` | `webhooks`, `verify(_:)` | Core, swift-crypto |
| `RazorpayPayments` | `payments` (incl. downtimes, OTP, VPA, methods) | Core |
| `RazorpayOrders` | `orders` | Payments |
| `RazorpayRefunds` | `refunds`, `payments.refund` | Payments |
| `RazorpayCustomers` | `customers` (incl. bank accounts) | Core |
| `RazorpayTokens` | `tokens` | Payments |
| `RazorpayCards` | `cards` | Payments |
| `RazorpayPaymentLinks` | `paymentLinks` | Core |
| `RazorpayQRCodes` | `qrCodes` | Payments |
| `RazorpayRoute` | `transfers`, `linkedAccounts` | Core |
| `RazorpaySmartCollect` | `virtualAccounts`, `fundAccounts` | Payments |
| `RazorpayItems` | `items` | Core |
| `RazorpayInvoices` | `invoices` | Core |
| `RazorpaySubscriptions` | `plans`, `subscriptions` | Items |
| `RazorpayAddons` | `addons` | Items |
| `RazorpayProducts` | `accountProducts` | Core |
| `RazorpaySettlements` | `settlements`, `iins` | Core |
| `RazorpayPartners` | `accounts`, `webhookEndpoints` | Core |
| `RazorpayLegacy` | deprecated `client.payment`, `client.order`, … | Core |

Picking fewer modules compiles less code and skips swift-crypto unless you verify signatures.
The dependency builds (SwiftNIO, AsyncHTTPClient) are the same either way.

### Webhooks without the umbrella

Without `RazorpayKit` there's no ``WebhookEvent``. Switch on the envelope's name and decode the
entity you need:

```swift
let webhook = try razorpay.webhooks.verify(body, signature: header)
if webhook.name == .paymentCaptured {
    let payment = try webhook.entity(Payment.self)
}
```
