# Payment downtimes

Hide payment methods that are failing right now, and bring them back when Razorpay says they recovered.

## Overview

Razorpay reports outages of banks, card networks and issuers, and UPI apps and handles as ``Downtime``
values. Each one names a ``Downtime/method``, a ``Downtime/Instrument`` and a ``Downtime/severity``.

### Poll before showing checkout

```swift
let downtimes = try await razorpay.payments.downtimes()
let failingBanks = Set(downtimes.filter { $0.isOngoing && $0.method == .netbanking }.compactMap(\.instrument.bank))
let upiDown = downtimes.contains { $0.isOngoing && $0.method == .upi && $0.instrument.isAll }
```

The endpoint isn't paginated; cache the result for a minute or two rather than calling it per request.

### React to webhooks

Subscribe to `payment.downtime.started`, `payment.downtime.updated` and `payment.downtime.resolved`:

```swift
switch try razorpay.webhooks.verify(body, signature: header).event {
case .downtimeStarted(let d), .downtimeUpdated(let d): await statusBoard.mark(d)
case .downtimeResolved(let d): await statusBoard.clear(d.id)
default: break
}
```

### Caveats

- ``Downtime/end`` is `nil` while Razorpay doesn't know when the outage will end. Don't treat `nil` as "over".
- A scheduled downtime can be `cancelled` and never start; ``Downtime/isOngoing`` is `false` for it.
- Razorpay's docs use both `started` and `updated` for ongoing downtimes, so check ``Downtime/isOngoing``
  instead of a single status. Unknown statuses, methods and severities decode without failing.
- The API calls the card kind `card_type` and webhooks call it `type`; both land in ``Downtime/Instrument/cardType``.
- `"ALL"` in `network` or `vpa_handle` means every network or handle: see ``Downtime/Instrument/isAll``.
