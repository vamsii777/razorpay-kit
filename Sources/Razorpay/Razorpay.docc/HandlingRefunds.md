# Handling Refunds

Learn how to process and manage refunds for payments made through Razorpay.

## Overview

The Razorpay SDK provides comprehensive support for processing refunds, both full and partial. This guide covers the various aspects of handling refunds in your application.

## Processing Refunds

### Full Refund

Process a full refund for a payment:

```swift
client.refundPayment(
    paymentId: "pay_123"
) { result in
    switch result {
    case .success(let refund):
        print("Refund processed: \(refund.id)")
        print("Amount refunded: \(refund.amount)")
    case .failure(let error):
        handleRefundError(error)
    }
}
```

### Partial Refund

Process a partial refund with specific amount:

```swift
client.refundPayment(
    paymentId: "pay_123",
    amount: 50000, // ₹500.00 in paise
    notes: ["reason": "Customer request"]
) { result in
    switch result {
    case .success(let refund):
        handleSuccessfulRefund(refund)
    case .failure(let error):
        handleRefundError(error)
    }
}
```

## Refund Status

### Checking Refund Status

Monitor the status of a refund:

```swift
client.fetchRefund(
    paymentId: "pay_123",
    refundId: "rfnd_123"
) { result in
    switch result {
    case .success(let refund):
        switch refund.status {
        case .processed:
            print("Refund processed")
        case .processing:
            print("Refund in progress")
        case .failed:
            print("Refund failed")
        }
    case .failure(let error):
        handleRefundError(error)
    }
}
```

### Listing All Refunds

Fetch all refunds for a payment:

```swift
client.fetchAllRefunds(
    paymentId: "pay_123"
) { result in
    switch result {
    case .success(let refunds):
        for refund in refunds {
            print("Refund ID: \(refund.id)")
            print("Amount: \(refund.amount)")
            print("Status: \(refund.status)")
        }
    case .failure(let error):
        handleRefundError(error)
    }
}
```

## Handling Responses

### Successful Refund

Handle successful refund response:

```swift
func handleSuccessfulRefund(_ refund: Refund) {
    // Update UI
    updateRefundStatus(refund.status)
    
    // Store refund details
    saveRefundDetails(
        refundId: refund.id,
        amount: refund.amount,
        status: refund.status
    )
    
    // Notify user
    notifyRefundSuccess(refund)
}
```

### Error Handling

Implement robust error handling:

```swift
func handleRefundError(_ error: Error) {
    if let razorpayError = error as? RazorpayError {
        switch razorpayError {
        case .invalidRequest(let message):
            showError("Invalid refund request: \(message)")
        case .authenticationError:
            showError("Authentication failed")
        case .serverError(let message):
            showError("Refund processing error: \(message)")
        }
    }
}
```

## Best Practices

### Amount Validation

Validate refund amount before processing:

```swift
func validateRefundAmount(
    refundAmount: Int,
    paymentAmount: Int
) -> Bool {
    // Check if refund amount is valid
    guard refundAmount > 0 else {
        return false
    }
    
    // Check if refund amount doesn't exceed payment amount
    guard refundAmount <= paymentAmount else {
        return false
    }
    
    return true
}
```

### Refund Notes

Add detailed notes for better tracking:

```swift
let refundNotes: [String: String] = [
    "reason": "Customer dissatisfied",
    "request_date": ISO8601DateFormatter().string(from: Date()),
    "requested_by": "support_agent_123"
]
```

## Topics

### Essential Refund Operations

- ``Refund``
- ``Refund/Status``
- ``Payment``

### Related Types

- ``RazorpayClient``
- ``RazorpayError`` 