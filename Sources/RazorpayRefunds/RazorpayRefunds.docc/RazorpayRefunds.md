# ``RazorpayRefunds``

Refunds, including `payments.refund(_:_:)`.

## Overview

Add the product and import it next to `RazorpayCore`:

```swift
.product(name: "RazorpayRefunds", package: "razorpay-kit")
```

```swift
import RazorpayCore
import RazorpayRefunds
```

It depends on `RazorpayPayments`, which SwiftPM adds for you.

`import RazorpayKit` includes this module too.

## Topics

### Models

- ``Refund``
