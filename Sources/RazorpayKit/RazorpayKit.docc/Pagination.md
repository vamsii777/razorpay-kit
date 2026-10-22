# Pagination

Every `list` returns a ``RazorpayList``, an `AsyncSequence` that fetches pages as you iterate.

```swift
for try await payment in razorpay.payments.list(.init(from: lastWeek)) {
    print(payment.id, payment.amount)
}

let latest = try await razorpay.orders.list(.init(limit: 20)).collect()
```

- ``ListOptions/pageSize`` is clamped to Razorpay's 1...100, and is 100 by default.
- Iteration stops on an empty or short page, at ``ListOptions/limit``, or when Razorpay sends the
  same page twice, so it can't loop forever.
- Errors (rate limits, for example) are ``RazorpayError`` and stop the loop. Items you have
  already received stay valid.
- Use ``ListOptions/filters`` for endpoint-specific filters such as `receipt`.
