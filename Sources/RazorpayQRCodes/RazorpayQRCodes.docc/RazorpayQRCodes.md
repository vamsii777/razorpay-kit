# ``RazorpayQRCodes``

UPI and Bharat QR codes and the payments made to them.

## Overview

Add the product and import it next to `RazorpayCore`:

```swift
.product(name: "RazorpayQRCodes", package: "razorpay-kit")
```

```swift
import RazorpayCore
import RazorpayQRCodes
```

It depends on `RazorpayPayments`, which SwiftPM adds for you.

`import RazorpayKit` includes this module too.

## Topics

### Models

- ``QRCode``
