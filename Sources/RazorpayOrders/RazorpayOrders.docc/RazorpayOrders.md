# ``RazorpayOrders``

Orders and the payments made against them.

## Overview

Add the product and import it next to `RazorpayCore`:

```swift
.product(name: "RazorpayOrders", package: "razorpay-kit")
```

```swift
import RazorpayCore
import RazorpayOrders
```

It depends on `RazorpayPayments`, which SwiftPM adds for you.

`import RazorpayKit` includes this module too.

## Topics

### Models

- ``Order``
