# Processing Payments

Learn how to process payments using various payment methods in Razorpay.

## Overview

The Razorpay SDK supports multiple payment methods including cards, UPI, netbanking, and wallets. This guide explains how to implement and handle different payment methods.

## Payment Methods

### Card Payments

Process credit and debit card payments:

```swift
let cardDetails = Card(
    number: "4111111111111111",
    expiryMonth: "12",
    expiryYear: "24",
    cvv: "123",
    name: "John Doe"
)

client.processCardPayment(
    orderId: "order_123",
    card: cardDetails
) { result in
    switch result {
    case .success(let payment):
        handleSuccessfulPayment(payment)
    case .failure(let error):
        handlePaymentError(error)
    }
}
```

### UPI Payments

Process UPI payments using VPA (Virtual Payment Address):

```swift
let upiDetails = UPIDetails(
    vpa: "user@upi"
)

client.processUPIPayment(
    orderId: "order_123",
    upi: upiDetails
) { result in
    switch result {
    case .success(let payment):
        handleSuccessfulPayment(payment)
    case .failure(let error):
        handlePaymentError(error)
    }
}
```

### Netbanking

Process payments through netbanking:

```swift
client.processNetbankingPayment(
    orderId: "order_123",
    bankCode: "HDFC"
) { result in
    switch result {
    case .success(let payment):
        handleSuccessfulPayment(payment)
    case .failure(let error):
        handlePaymentError(error)
    }
}
```

## Payment Status

### Checking Payment Status

Monitor the status of a payment:

```swift
client.fetchPayment(paymentId) { result in
    switch result {
    case .success(let payment):
        switch payment.status {
        case .created:
            print("Payment initiated")
        case .authorized:
            print("Payment authorized")
        case .captured:
            print("Payment captured")
        case .refunded:
            print("Payment refunded")
        case .failed:
            print("Payment failed")
        }
    case .failure(let error):
        handlePaymentError(error)
    }
}
```

### Handling Payment Response

Process payment response and update UI:

```swift
func handleSuccessfulPayment(_ payment: Payment) {
    // Update UI
    updatePaymentStatus(payment.status)
    
    // Store payment details
    savePaymentDetails(
        paymentId: payment.id,
        amount: payment.amount,
        method: payment.method
    )
    
    // Trigger success callback
    notifyPaymentSuccess(payment)
}

func handlePaymentError(_ error: Error) {
    if let razorpayError = error as? RazorpayError {
        switch razorpayError {
        case .invalidRequest(let message):
            showError("Invalid payment details: \(message)")
        case .authenticationError:
            showError("Payment authentication failed")
        case .serverError(let message):
            showError("Payment processing error: \(message)")
        }
    }
}
```

## Payment Verification

### Verifying Payment Signature

Verify payment signature to ensure authenticity:

```swift
let signature = "razorpay_signature"
let orderId = "order_123"
let paymentId = "pay_123"

client.verifyPaymentSignature(
    orderId: orderId,
    paymentId: paymentId,
    signature: signature
) { isValid in
    if isValid {
        print("Payment signature verified")
    } else {
        print("Invalid payment signature")
    }
}
```

## Best Practices

- Always verify payment signatures
- Implement proper error handling
- Store payment details securely
- Update UI promptly with payment status
- Handle network errors gracefully
- Implement retry logic for failed payments
- Log payment events for debugging

## Topics

### Essential Payment Operations

- ``Payment``
- ``Payment/Status``
- ``Payment/Method``
- ``Payment/Card``
- ``Payment/UPIDetails``

### Related Types

- ``RazorpayClient``
- ``RazorpayError``
- ``OrderResponse`` 