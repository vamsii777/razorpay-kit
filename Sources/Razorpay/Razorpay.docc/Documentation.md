# ``Razorpay``

A Swift package that provides a type-safe interface to interact with the Razorpay payment gateway.

## Overview

The Razorpay Swift package provides a comprehensive set of tools and models to integrate Razorpay payment gateway into your iOS or macOS applications. It offers type-safe APIs for creating orders, processing payments, and handling various payment-related operations.

## Installation

You can add Razorpay as a dependency to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/vamsii777/razorpay-kit.git", from: "1.0.0")
]
```

## Topics

### Essentials

- <doc:GettingStarted>
- ``RazorpayClient``

### Payment Processing

- ``Payment``
- ``OrderRequest``
- ``OrderResponse``

### Models

- ``Payment/Status``
- ``Payment/Method``
- ``Payment/RefundStatus``
- ``Payment/UPIDetails``
- ``Payment/Card``
- ``Payment/EMIDetails``
- ``OrderResponse/Status``

### Error Handling

- ``RazorpayError``

### Articles

- <doc:CreatingOrders>
- <doc:ProcessingPayments>
- <doc:HandlingRefunds>

# Getting Started

@Metadata {
    @PageKind(article)
}

## Creating a Razorpay Client

To get started with the Razorpay SDK, create a client instance with your API credentials:

```swift
let client = RazorpayClient(
    keyId: "your_key_id",
    keySecret: "your_key_secret"
)
```

## Creating an Order

Create a new order using the `OrderRequest` model:

```swift
let orderRequest = OrderRequest(
    amount: 100000, // Amount in paise (₹1000.00)
    currency: "INR",
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

## Processing Payments

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

# Creating Orders

@Metadata {
    @PageKind(article)
}

## Overview

Orders are the first step in the payment process. An order represents the intent to collect payment and contains information about the amount, currency, and other optional details.

## Creating a Basic Order

```swift
let orderRequest = OrderRequest(
    amount: 100000,
    currency: "INR"
)
```

## Adding Optional Details

You can include additional information with your order:

```swift
let orderRequest = OrderRequest(
    amount: 100000,
    currency: "INR",
    receipt: "order_123",
    notes: ["customer_name": "John Doe"],
    partialPayment: true,
    firstPaymentMinAmount: 50000
)
```

## Handling Order Response

The order response contains important information about the created order:

```swift
client.createOrder(orderRequest) { result in
    switch result {
    case .success(let order):
        print("Order ID: \(order.id)")
        print("Amount: \(order.amount)")
        print("Status: \(order.status)")
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

# Processing Payments

@Metadata {
    @PageKind(article)
}

## Overview

The Razorpay SDK supports various payment methods including cards, UPI, netbanking, and wallets.

## Payment Methods

### Card Payments

```swift
let cardDetails = Card(
    number: "4111111111111111",
    expiryMonth: "12",
    expiryYear: "24",
    cvv: "123"
)
```

### UPI Payments

```swift
let upiDetails = UPIDetails(
    vpa: "user@upi"
)
```

## Handling Payment Response

```swift
client.fetchPayment(paymentId) { result in
    switch result {
    case .success(let payment):
        if payment.status == .captured {
            print("Payment successful")
        }
    case .failure(let error):
        print("Payment failed: \(error)")
    }
}
```

# Handling Refunds

@Metadata {
    @PageKind(article)
}

## Overview

The SDK provides functionality to process full and partial refunds for payments.

## Processing Refunds

```swift
client.refundPayment(
    paymentId: "pay_123",
    amount: 50000 // Partial refund of ₹500
) { result in
    switch result {
    case .success(let refund):
        print("Refund processed: \(refund.id)")
    case .failure(let error):
        print("Refund failed: \(error)")
    }
}
```