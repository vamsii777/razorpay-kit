# ``RazorpayLegacy``

The beta.1 `[String: Any]` routes (`client.payment`, `client.order`, …). Deprecated where a typed module exists; use `client.raw` for anything else.

## Overview

Add the product and import it next to `RazorpayCore`:

```swift
.product(name: "RazorpayLegacy", package: "razorpay-kit")
```

```swift
import RazorpayCore
import RazorpayLegacy
```

`import RazorpayKit` includes this module too.

