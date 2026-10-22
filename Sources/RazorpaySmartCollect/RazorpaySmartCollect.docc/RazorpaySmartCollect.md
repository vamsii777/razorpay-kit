# ``RazorpaySmartCollect``

Smart Collect virtual accounts, bank transfers and customer fund accounts.

## Overview

Add the product and import it next to `RazorpayCore`:

```swift
.product(name: "RazorpaySmartCollect", package: "razorpay-kit")
```

```swift
import RazorpayCore
import RazorpaySmartCollect
```

It depends on `RazorpayPayments`, which SwiftPM adds for you.

`import RazorpayKit` includes this module too.

## Topics

### Models

- ``VirtualAccount``
- ``BankTransfer``
- ``FundAccount``
