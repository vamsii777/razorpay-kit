# Processing Payments

@Metadata {
    @PageKind(article)
}

## Overview

The Razorpay SDK supports various payment methods including cards, UPI, netbanking, wallets, and EMI options.

## Payment Methods

### Card Payments

The SDK supports all major card networks and types:

```swift
// Card payment information
let payment = try await client.fetchPayment(paymentId)
if let card = payment.card {
    print("Card Network: \(card.network)") // Visa, MasterCard, etc.
    print("Card Type: \(card.type)") // credit, debit, prepaid
    print("Card Last4: \(card.last4)")
    print("EMI Eligible: \(card.emi)")
}
```

### UPI Payments

Handle UPI payments with detailed information:

```swift
if let upi = payment.upi {
    print("VPA Used: \(upi.vpa)")
    if let accountType = upi.payerAccountType {
        switch accountType {
        case .bankAccount:
            print("Paid using bank account")
        case .creditCard:
            print("Paid using credit card")
        case .wallet:
            print("Paid using wallet")
        }
    }
}
```

### EMI Payments

Process EMI payments with detailed plan information:

```swift
if let emi = payment.emi {
    print("Bank: \(emi.bank)")
    print("Tenure: \(emi.tenure) months")
    print("Interest Rate: \(emi.interestRate)%")
    print("EMI Amount: ₹\(emi.emiAmount/100)")
    print("Total Amount: ₹\(emi.totalAmount/100)")
}
```

## Payment Status Tracking

Monitor payment status through various stages:

```swift
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
```

## Error Handling

Handle payment failures with detailed error information:

```swift
if let errorCode = payment.errorCode {
    print("Error Code: \(errorCode)")
    print("Error Description: \(payment.errorDescription ?? "Unknown")")
    print("Error Source: \(payment.errorSource ?? "Unknown")")
    print("Error Step: \(payment.errorStep ?? "Unknown")")
}
```

## Additional Features

### Acquirer Data

Access detailed transaction information:

```swift
if let acquirerData = payment.acquirerData {
    print("Bank Transaction ID: \(acquirerData.bankTransactionId ?? "")")
    print("Auth Code: \(acquirerData.authCode ?? "")")
    print("ARN: \(acquirerData.arn ?? "")")
}
```

### Offers and Discounts

Handle offers applied to payments:

```swift
if let offers = payment.offers {
    print("Number of offers applied: \(offers.count)")
    offers.items.forEach { offer in
        print("Offer ID: \(offer.id)")
    }
}
```

### International Payments

Handle international transactions:

```swift
if payment.international {
    print("International payment")
    print("Currency: \(payment.currency)")
}
```

## Best Practices

1. Always verify payment status on your server
2. Implement proper webhook handling
3. Store payment IDs for future reference
4. Handle partial payments when enabled
5. Implement proper error recovery
6. Follow security guidelines for handling sensitive data
7. Maintain proper logs for debugging and auditing

## Topics

### Essential Payment Operations

- ``Payment``
- ``Payment/Status``
- ``Payment/Method``