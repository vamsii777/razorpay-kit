# Billing: Items, Invoices, Plans, Subscriptions and Add-ons

Typed billing APIs, each in its own module.

## Overview

| Module | Namespace | Razorpay docs |
|---|---|---|
| `RazorpayItems` | ``RazorpayClient/items`` | [Items](https://razorpay.com/docs/api/payments/items/) |
| `RazorpayInvoices` | ``RazorpayClient/invoices`` | [Invoices](https://razorpay.com/docs/api/payments/invoices/) |
| `RazorpaySubscriptions` | ``RazorpayClient/plans``, ``RazorpayClient/subscriptions`` | [Subscriptions](https://razorpay.com/docs/api/payments/subscriptions/) |
| `RazorpayAddons` | ``RazorpayClient/addons`` | [Add-ons](https://razorpay.com/docs/api/payments/subscriptions/#create-an-add-on) |
| `RazorpayProducts` | ``RazorpayClient/accountProducts`` | [Product configuration](https://razorpay.com/docs/api/partners/product-configuration/) |

`import RazorpayKit` brings them all in. To depend on less, add just the products you use, for example
`.product(name: "RazorpaySubscriptions", package: "razorpay-kit")`.

```swift
let plan = try await razorpay.plans.create(.init(period: .monthly, item: .init(name: "Pro", amount: .inr(rupees: 499))))
let subscription = try await razorpay.subscriptions.create(.init(planID: plan.id, totalCount: 12))

let invoice = try await razorpay.invoices.create(.init(
    customerID: "cust_…",
    lineItems: [.item("item_…", quantity: 2), .custom(name: "Shipping", amount: .inr(rupees: 50))],
    draft: true))
_ = try await razorpay.invoices.issue(invoice.id)

for try await sub in razorpay.subscriptions.list(.init(filters: ["plan_id": plan.id.rawValue])) {
    if sub.status == .halted { … }
}
```

Statuses and other server enums are open: values this SDK doesn't know yet decode and are kept in `rawValue`.
Deletes (`items.delete`, `invoices.delete`, `addons.delete`) succeed on any 2xx response and throw
``RazorpayError`` otherwise.

Webhooks: ``Invoice`` and ``Subscription`` conform to `WebhookEntity`, so
`try webhook.entity(Subscription.self)` decodes the `subscription.*` payloads.

## Topics

### Items
- ``Item``
- ``RazorpayClient/Items``

### Invoices
- ``Invoice``
- ``RazorpayClient/Invoices``

### Plans and subscriptions
- ``Plan``
- ``Subscription``
- ``RazorpayClient/Plans``
- ``RazorpayClient/Subscriptions``

### Add-ons
- ``Addon``
- ``RazorpayClient/Addons``

### Partner product configuration
- ``AccountProduct``
- ``ProductTerms``
- ``RazorpayClient/AccountProducts``
