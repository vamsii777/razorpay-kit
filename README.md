# RazorpayKit
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fvamsii777%2Frazorpay-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/vamsii777/razorpay-kit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fvamsii777%2Frazorpay-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/vamsii777/razorpay-kit)

RazorpayKit is a Swift library for integrating with Razorpay's payment gateway. It supports managing orders, payments, subscriptions, webhooks and more.

## Installation

### Swift Package Manager

You can add RazorpayKit to your project via Swift Package Manager (SPM) by adding the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/vamsii777/razorpay-kit.git", from: "0.0.11")
]
```


### Modules

Depend on `RazorpayKit` for everything, or on single areas such as `RazorpayPayments`, `RazorpayOrders`,
`RazorpayRefunds`, `RazorpayCustomers`, `RazorpayTokens`, `RazorpayCards`, `RazorpayPaymentLinks`, `RazorpayQRCodes`,
`RazorpayRoute`, `RazorpaySmartCollect`, `RazorpayItems`, `RazorpayInvoices`, `RazorpaySubscriptions`, `RazorpayAddons`,
`RazorpayProducts`, `RazorpaySettlements` and `RazorpayVerification` (signatures and webhooks). Each adds its namespace to
the same `RazorpayClient`. See the "Choosing modules" DocC article.

## Quick start (1.0)

```swift
import RazorpayKit

let razorpay = RazorpayClient(key: keyID, secret: keySecret, webhookSecret: webhookSecret)

let order = try await razorpay.orders.create(.init(amount: .inr(rupees: 499), receipt: "rcpt_42"))
try razorpay.verify(checkoutResponse)                       // Checkout signature
let payment = try await razorpay.payments.capture(checkoutResponse.paymentID, amount: order.amount)

for try await refund in razorpay.payments.refunds(of: payment.id) { print(refund.status) }

let event = try razorpay.webhooks.verify(rawBody, signature: signatureHeader).event
if case .paymentCaptured(let captured) = event { fulfil(captured) }
```

Every call is async, models are `Sendable` and `Codable`, and the only error type is `RazorpayError`,
which Swift 6 compilers enforce with `throws(RazorpayError)`. It builds on Swift 5.10 or later. See the DocC
catalog in `Sources/RazorpayKit/RazorpayKit.docc`, including the migration guide.

## Using with Vapor

There is no Vapor dependency. Create one client on Vapor's HTTP client, store it, and verify webhooks over the raw body:

```swift
app.razorpay = RazorpayClient(app.http.client.shared, key: keyID, secret: keySecret, webhookSecret: webhookSecret)

app.on(.POST, "webhooks", "razorpay", body: .collect(maxSize: "1mb")) { req async throws -> HTTPStatus in
    guard let body = req.body.data else { throw Abort(.badRequest) }
    let event = try req.razorpay.webhooks.verify(body.readableBytesView,
                                                 signature: req.headers.first(name: "X-Razorpay-Signature")).event
    if case .paymentCaptured(let payment) = event { try await fulfil(payment) }
    return .ok
}
```

The full example, including the `app.razorpay` storage extension, is in the DocC article `Vapor.md`.

## Using the API (dictionary routes, deprecated)

These `[String: Any]` routes live in `RazorpayLegacy` and are deprecated wherever a typed module exists.

Initialize the `RazorpayClient` with your Razorpay API key, secret, and environment. This client will be your gateway to interacting with the Razorpay API.


```swift
let httpClient = HTTPClient(...)
let razorpay = RazorpayClient(httpClient: httpClient, key: "rzp_test_12345", secret: "your_secret")
```

And now you have access to the APIs via `razorpay`.

The APIs you have available correspond to what's implemented.

For example to use the `orders` API, the razorpayClient has a property to access that API via routes.

#### Creating an Order

```swift
let orderData = [
    "amount": 50000, // Specify amount in the smallest currency unit.
    "currency": "INR",
    "receipt": "order_rcptid_11"
]

let order = try await razorpayClient.order.create(data: orderData)
print("Created Order: \(order)")
```

#### Fetching a Payment

```swift
let paymentId = "pay_29QQoUBi66xm2f"
let payment = try await razorpayClient.payment.fetch(paymentID: paymentId)
print("Fetched Payment: \(payment)")
```

#### Managing Subscriptions

```swift
let subscriptionId = "sub_00000000000001"
let subscription = try await razorpayClient.subscription.fetch(subscriptionID: subscriptionId)
print("Fetched Subscription: \(subscription)")
```

## What's Implemented

### Core Resources
* [x] **Accounts**
* [x] **Addons**
* [x] **Cards**
* [x] **Customers**
* [x] **Fund Accounts**
* [x] **IIN (Issuer Identification Number)**
* [x] **Invoices**
* [x] **Items**
* [x] **Orders**
* [x] **Payments**
* [x] **Payment Links**
* [x] **Products**
* [x] **QR Codes**
* [x] **Refunds**
* [x] **Settlements**
* [x] **Stakeholders**
* [x] **Subscriptions**
* [x] **Tokens**
* [x] **Transfers**
* [x] **Virtual Accounts**
* [x] **Webhooks**

### Additional Features
* [x] **Authentication**: Securely authenticate using your Razorpay key and secret.
* [x] **Headers Management**: Customize request headers for special use cases such as idempotent requests.
* [x] **Asynchronous API Calls**: Support for Swift's modern async/await pattern for clean and simple asynchronous API calls.


## LICENSE
RazorpayKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.