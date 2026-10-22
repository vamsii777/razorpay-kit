# Using RazorpayKit with Vapor

RazorpayKit doesn't depend on Vapor, but it plugs in with a few lines.

## Store one client

Create the client once, reusing Vapor's HTTP client, and keep it in `app.storage`:

```swift
import Vapor
import RazorpayKit

extension Application {
    private struct RazorpayKey: StorageKey { typealias Value = RazorpayClient }

    var razorpay: RazorpayClient {
        get { storage[RazorpayKey.self]! }
        set { storage[RazorpayKey.self] = newValue }
    }
}

extension Request {
    var razorpay: RazorpayClient { application.razorpay }
}

// configure.swift
app.razorpay = RazorpayClient(
    app.http.client.shared,                       // or HTTPClient.shared
    key: Environment.get("RAZORPAY_KEY_ID")!,
    secret: Environment.get("RAZORPAY_KEY_SECRET")!,
    webhookSecret: Environment.get("RAZORPAY_WEBHOOK_SECRET")
)
```

``RazorpayClient`` is a `Sendable` struct, so sharing it across requests is safe.

## Verify a webhook in a route

Verify the **raw** body bytes. Don't decode the content first:

```swift
app.on(.POST, "webhooks", "razorpay", body: .collect(maxSize: "1mb")) { req async throws -> HTTPStatus in
    guard let body = req.body.data else { throw Abort(.badRequest) }
    do {
        let event = try req.razorpay.webhooks.verify(
            body.readableBytesView,
            signature: req.headers.first(name: "X-Razorpay-Signature")).event
        switch event {
        case .paymentCaptured(let payment): try await fulfil(payment, on: req.db)
        case .refundProcessed(let refund):  req.logger.info("refund \(refund.id) processed")
        default: break
        }
        return .ok
    } catch RazorpayError.signatureMismatch {
        throw Abort(.unauthorized)
    }
}
```

## Create an order and verify Checkout

```swift
app.post("orders") { req async throws -> String in
    let order = try await req.razorpay.orders.create(.init(amount: .inr(rupees: 499)))
    return order.id.rawValue
}

app.post("checkout", "verify") { req async throws -> HTTPStatus in
    let response = try req.content.decode(CheckoutResponse.self)   // razorpay_* fields
    try req.razorpay.verify(response)
    return .ok
}
```
