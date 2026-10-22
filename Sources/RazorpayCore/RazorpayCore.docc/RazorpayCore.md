# ``RazorpayCore``

The client, transport, errors, money, IDs, pagination and the raw escape hatch shared by every module.

## Overview

Add the product and import it next to `RazorpayCore`:

```swift
.product(name: "RazorpayCore", package: "razorpay-kit")
```

```swift
import RazorpayCore
import RazorpayCore
```

`import RazorpayKit` includes this module too.

## Topics

### Models

- ``RazorpayClient``
- ``RazorpayTransport``
- ``RequestOptions``
- ``RazorpayError``
- ``Money``
- ``Currency``
- ``RazorpayID``
- ``RazorpayList``
- ``ListOptions``
- ``JSONValue``
- ``RazorpayWebhook``
- ``BankAccount``
- ``VPAAddress``
