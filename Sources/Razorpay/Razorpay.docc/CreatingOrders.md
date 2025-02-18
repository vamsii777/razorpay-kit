# Creating Orders

Learn how to create and manage orders in Razorpay.

## Overview

Orders are the foundation of the payment process in Razorpay. An order represents the intent to collect payment and must be created before accepting payments from customers.

## Creating Orders

### Basic Order Creation

Create a simple order with just the required fields:

```swift
let orderRequest = OrderRequest(
    amount: 100000, // ₹1000.00 in paise
    currency: "INR"
)
```

### Advanced Order Creation

Include additional details for better tracking and management:

```swift
let orderRequest = OrderRequest(
    amount: 100000,
    currency: "INR",
    receipt: "order_rcptid_123",
    notes: [
        "customer_name": "John Doe",
        "customer_email": "john@example.com"
    ],
    partialPayment: true,
    firstPaymentMinAmount: 50000
)
```

## Order Properties

- `amount`: Payment amount in smallest currency unit (paise for INR)
- `currency`: Three-letter ISO currency code
- `receipt`: Your system's order reference
- `notes`: Additional information as key-value pairs
- `partialPayment`: Enable/disable partial payments
- `firstPaymentMinAmount`: Minimum amount for first partial payment

## Handling Responses

### Successful Order Creation

```swift
client.createOrder(orderRequest) { result in
    switch result {
    case .success(let order):
        print("Order ID: \(order.id)")
        print("Amount: \(order.amount)")
        print("Currency: \(order.currency)")
        print("Receipt: \(order.receipt ?? "Not provided")")
        print("Status: \(order.status)")
    case .failure(let error):
        handleError(error)
    }
}
```

### Order Status

Track the order status through its lifecycle:

```swift
client.fetchOrder(orderId) { result in
    switch result {
    case .success(let order):
        switch order.status {
        case .created:
            print("Order is created")
        case .attempted:
            print("Payment attempted")
        case .paid:
            print("Payment successful")
        }
    case .failure(let error):
        handleError(error)
    }
}
```

## Best Practices

### Amount Handling

Always convert amount to smallest currency unit:

```swift
func convertToSmallestUnit(_ amount: Double, currency: String) -> Int {
    switch currency {
    case "INR":
        return Int(amount * 100) // Convert to paise
    default:
        return Int(amount * 100) // Default to smallest unit
    }
}

// Usage
let amount = convertToSmallestUnit(1000.00, currency: "INR")
```

### Error Handling

Implement robust error handling:

```swift
func handleError(_ error: Error) {
    if let razorpayError = error as? RazorpayError {
        switch razorpayError {
        case .invalidRequest(let message):
            print("Invalid request: \(message)")
        case .authenticationError:
            print("Authentication failed")
        case .serverError(let message):
            print("Server error: \(message)")
        }
    }
}
```

## Topics

### Essential Order Operations

- ``OrderRequest``
- ``OrderResponse``
- ``OrderResponse/Status``

### Related Types

- ``Payment``
- ``RazorpayClient``
- ``RazorpayError`` 