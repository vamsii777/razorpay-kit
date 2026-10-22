# ``RazorpaySettlements``

Settlements, instant settlements, the reconciliation report and IIN lookup.
## Overview

| Namespace | What it covers | Razorpay docs |
|---|---|---|
| `settlements` | settlements, instant (on-demand) settlements, the combined recon report | [Settlements](https://razorpay.com/docs/api/settlements/) |
| `iins` | card and token IIN lookup, plus IIN lists by flow or sub-type | [IIN API](https://razorpay.com/docs/api/payments/cards/iin-api/) |

```swift
import RazorpayCore
import RazorpaySettlements   // or: import RazorpayKit

for try await setl in razorpay.settlements.list() { print(setl.id, setl.amount, setl.utr ?? "-") }

// Everything settled on 11 Sep 2019, page by page.
for try await entry in razorpay.settlements.recon(.init(year: 2019, month: 9, day: 11)) {
    if entry.type == .refund { … }
}

let instant = try await razorpay.settlements.createInstant(.init(amount: .inr(rupees: 2_000)))
let everything = try await razorpay.settlements.createInstant(.fullBalance(description: "month end"))
let detailed = try await razorpay.settlements.fetchInstant(instant.id, expandPayouts: true)

let card = try await razorpay.iins.fetch("412345")
let otpIINs = try await razorpay.iins.list(flow: .otp)
```

Invalid input (a recon month outside 1-12, or an IIN that isn't 6-9 digits) fails with
`RazorpayError.invalidRequest` before any request is sent. In the recon report, `notes` may arrive as
an object, a JSON-encoded string or `null`; all three decode into `Notes`.

## Topics

### Settlements
- ``Settlement``
- ``InstantSettlement``
- ``SettlementReconEntry``
- ``SettlementReconPeriod``

### IIN
- ``IIN``
