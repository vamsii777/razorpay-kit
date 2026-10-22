# ``RazorpayTokens``

Saved customer tokens for cards, UPI and eMandate.

## Overview

Add the product and import it next to `RazorpayCore`:

```swift
.product(name: "RazorpayTokens", package: "razorpay-kit")
```

```swift
import RazorpayCore
import RazorpayTokens
```

It depends on `RazorpayPayments`, which SwiftPM adds for you.

`import RazorpayKit` includes this module too.

## Topics

### Models

- ``Token``
- ``DeletionResult``
