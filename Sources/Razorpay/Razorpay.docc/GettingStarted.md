# Getting Started with Razorpay

Learn how to integrate Razorpay into your Swift application.

## Overview

This guide walks you through the basic setup and initial steps to start accepting payments using the Razorpay Swift SDK.

## Setting Up Your Environment

### Prerequisites

Before you begin, make sure you have:

- A Razorpay account with API credentials
- Xcode 13.0 or later
- iOS 13.0 or later / macOS 10.15 or later

### Installation

Add Razorpay to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/vamsii777/razorpay-kit.git", from: "1.0.0")
]
```

## Basic Configuration

### Initialize the Client

Create a Razorpay client instance with your API credentials:

```swift
import Razorpay

let client = RazorpayClient(
    keyId: "your_key_id",
    keySecret: "your_key_secret"
)
```

### Creating Your First Order

1. Create an order request:

```swift
let orderRequest = OrderRequest(
    amount: 100000, // Amount in paise (₹1000.00)
    currency: "INR",
    receipt: "order_123"
)
```

2. Submit the order:

```swift
client.createOrder(orderRequest) { result in
    switch result {
    case .success(let order):
        print("Order created: \(order.id)")
        // Present payment options to user
    case .failure(let error):
        print("Error: \(error)")
    }
}
```

## Best Practices

- Always store API credentials securely
- Handle errors gracefully
- Validate amounts before creating orders
- Implement proper error handling
- Use appropriate currency codes

## Next Steps

- Learn about different payment methods
- Implement webhooks for payment notifications
- Set up recurring payments
- Handle refunds

## Topics

### Essentials

- <doc:CreatingOrders>
- <doc:ProcessingPayments>
- <doc:HandlingRefunds>

### Related Types

- ``RazorpayClient``
- ``OrderRequest``
- ``OrderResponse``
- ``Payment`` 