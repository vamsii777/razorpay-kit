# Handling Refunds

@Metadata {
    @PageKind(article)
}

## Overview

The Razorpay SDK provides comprehensive support for processing refunds, both full and partial, with detailed tracking and status management.

## Processing Refunds

### Full Refund

Process a full refund for a payment:

```swift
// Using async/await
do {
    let refund = try await client.refundPayment(
        paymentId: "pay_123"
    )
    print("Full refund processed: \(refund.id)")
} catch {
    print("Refund failed: \(error)")
}

// Using completion handler
client.refundPayment(paymentId: "pay_123") { result in
    switch result {
    case .success(let refund):
        print("Full refund processed: \(refund.id)")
    case .failure(let error):
        print("Refund failed: \(error)")
    }
}
```

### Partial Refund

Process a partial refund with specific amount:

```swift
let refundRequest = RefundRequest(
    amount: 50000, // Partial refund of ₹500
    notes: ["reason": "Customer request"],
    receiptNumber: "refund_receipt_123"
)

try await client.refundPayment(
    paymentId: "pay_123",
    request: refundRequest
)
```

## Tracking Refund Status

Monitor the status of a refund:

```swift
let payment = try await client.fetchPayment("pay_123")

switch payment.refundStatus {
case .partial:
    print("Partial refund processed")
    print("Refunded amount: ₹\(payment.amountRefunded/100)")
    print("Remaining amount: ₹\(payment.amount - payment.amountRefunded)/100")
case .full:
    print("Full refund processed")
    print("Refunded amount: ₹\(payment.amountRefunded/100)")
case .none:
    print("No refunds processed")
}
```

## Fetching Refund Details

Retrieve detailed information about a specific refund:

```swift
let refund = try await client.fetchRefund(
    paymentId: "pay_123",
    refundId: "rfnd_123"
)

print("Refund ID: \(refund.id)")
print("Amount: ₹\(refund.amount/100)")
print("Status: \(refund.status)")
print("Created At: \(refund.createdAt)")
```

## Listing All Refunds

Get a list of all refunds for a payment:

```swift
let refunds = try await client.listRefunds(
    paymentId: "pay_123"
)

print("Total refunds: \(refunds.count)")
refunds.items.forEach { refund in
    print("Refund ID: \(refund.id)")
    print("Amount: ₹\(refund.amount/100)")
    print("Status: \(refund.status)")
}
```

## Speed Processing

Request faster refund processing:

```swift
let refundRequest = RefundRequest(
    amount: 100000,
    speed: .optimum,
    notes: ["priority": "high"]
)

try await client.refundPayment(
    paymentId: "pay_123",
    request: refundRequest
)
```

## Best Practices

1. Always verify refund eligibility before processing
2. Maintain proper records of refund transactions
3. Implement proper error handling for refund failures
4. Use webhooks to track refund status changes
5. Consider implementing refund policies
6. Handle partial refunds carefully
7. Keep customers informed about refund status
8. Implement proper logging for audit trails

## Error Handling

Handle refund-specific errors:

```swift
do {
    let refund = try await client.refundPayment(
        paymentId: "pay_123"
    )
} catch let error as RazorpayError {
    switch error {
    case .invalidRequest(let message):
        print("Invalid refund request: \(message)")
    case .authenticationError:
        print("Authentication failed")
    case .serverError(let message):
        print("Server error: \(message)")
    }
}
```

## Topics

### Related Types

- ``Payment``
- ``RefundRequest``
- ``RefundResponse``
- ``Payment/RefundStatus`` 