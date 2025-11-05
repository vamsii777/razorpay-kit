# ``Razorpay``

@Metadata {
    @PageKind(article)
}

A Swift package that provides a type-safe interface to interact with the Razorpay payment gateway.

## Overview

The Razorpay Swift package provides a comprehensive set of tools and models to integrate Razorpay payment gateway into your iOS, macOS, or server-side Swift applications. It offers type-safe APIs for creating orders, processing payments, and handling various payment-related operations.

## Installation

You can add Razorpay as a dependency to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/vamsii777/razorpay-kit.git", from: "1.0.0")
]
```

## Getting Started

### Creating a Razorpay Client

To get started with the Razorpay SDK, create a client instance with your API credentials:

```swift
let client = RazorpayClient(
    keyId: "your_key_id",
    keySecret: "your_key_secret"
)
```

### Creating an Order

Create a new order using the `OrderRequest` model:

```swift
let orderRequest = OrderRequest(
    amount: 100000, // Amount in paise (₹1000.00)
    currency: .indianRupee,
    receipt: "order_123",
    notes: ["customer_name": "John Doe"]
)

client.createOrder(orderRequest) { result in
    switch result {
    case .success(let order):
        print("Order created: \(order.id)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

### Processing Payments

Once an order is created, you can process payments using various payment methods:

```swift
// Fetch payment details
client.fetchPayment("payment_id") { result in
    switch result {
    case .success(let payment):
        print("Payment status: \(payment.status)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

## Error Handling

The SDK provides comprehensive error handling through the `RazorpayError` type:

```swift
if let error = error as? RazorpayError {
    switch error {
    case .invalidRequest(let message):
        print("Invalid request: \(message)")
    case .authenticationError:
        print("Authentication failed")
    case .serverError(let message):
        print("Server error: \(message)")
    }
}
```

## Topics

### Essentials

- <doc:GettingStarted>
- ``RazorpayClient``

### Payment Processing

- ``Payment``
- ``OrderRequest``
- ``OrderResponse``
- ``PaymentCollection``

### Models

- ``Payment/Status``
- ``Payment/Method``
- ``Payment/RefundStatus``
- ``Payment/UPIDetails``
- ``Payment/Card``
- ``Payment/EMIDetails``
- ``Payment/OffersDetails``
- ``Payment/AcquirerData``
- ``OrderResponse/Status``

### Payment Methods

- ``Payment/Card/Network``
- ``Payment/Card/CardType``
- ``Payment/Card/SubType``
- ``Payment/UPIDetails/PayerAccountType``

### Error Handling

- ``RazorpayError``

### Articles

- <doc:CreatingOrders>
- <doc:ProcessingPayments>
- <doc:HandlingRefunds>
