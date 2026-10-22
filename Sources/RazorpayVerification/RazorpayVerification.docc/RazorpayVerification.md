# ``RazorpayVerification``

Payment, subscription, Payment Link and webhook signature checks. The only module that uses swift-crypto.

## Overview

Add the product and import it next to `RazorpayCore`:

```swift
.product(name: "RazorpayVerification", package: "razorpay-kit")
```

```swift
import RazorpayCore
import RazorpayVerification
```

`import RazorpayKit` includes this module too.

## Topics

### Models

- ``RazorpaySignature``
- ``CheckoutResponse``
- ``PaymentLinkCallback``
