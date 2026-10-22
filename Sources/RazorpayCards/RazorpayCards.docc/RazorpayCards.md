# ``RazorpayCards``

Cards by ID and card network references (PAR).

## Overview

Add the product and import it next to `RazorpayCore`:

```swift
.product(name: "RazorpayCards", package: "razorpay-kit")
```

```swift
import RazorpayCore
import RazorpayCards
```

It depends on `RazorpayPayments`, which SwiftPM adds for you.

`import RazorpayKit` includes this module too.

## Topics

### Models

- ``CardReference``
- ``CardReferenceRequest``
