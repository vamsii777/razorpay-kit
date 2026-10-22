# ``RazorpayPayments``

Payments, payment downtimes, cards on payments, payment methods, UPI/VPA validation, S2S JSON and recurring payments, and native OTP.

## Overview

Add the product and import it next to `RazorpayCore`:

```swift
.product(name: "RazorpayPayments", package: "razorpay-kit")
```

```swift
import RazorpayCore
import RazorpayPayments
```

`import RazorpayKit` includes this module too.

## Topics

### Models

- ``Payment``
- ``Downtime``
- ``Card``
- ``PaymentMethods``
- ``VPAValidation``
- ``PaymentRequest``
- ``RecurringPaymentRequest``
- ``PaymentResult``
- ``PaymentAction``
