# Partners: sub-merchant accounts and webhook management

Typed APIs in the `RazorpayPartners` module.

## Overview

| Namespace | What it covers | Razorpay docs |
|---|---|---|
| ``RazorpayClient/accounts`` | create, fetch, update and delete sub-merchant accounts (`/v2/accounts`) | [Account onboarding](https://razorpay.com/docs/api/partners/account-onboarding/) |
| ``RazorpayClient/webhookEndpoints`` | register, list, fetch, update and delete webhooks on your account (`/v1/webhooks`) or a sub-merchant's (`/v2/accounts/{id}/webhooks`) | [Webhooks](https://razorpay.com/docs/api/partners/webhooks/) |

Product configuration for these accounts is in `RazorpayProducts` (``RazorpayClient/accountProducts``).

```swift
import RazorpayPartners   // or: import RazorpayKit

let account = try await razorpay.accounts.create(.init(
    email: "owner@example.org", phone: "9000090000",
    legalBusinessName: "Acme Corp", businessType: "partnership",
    profile: ["category": "healthcare", "subcategory": "clinic"]))

let hook = try await razorpay.webhookEndpoints.create(
    .init(url: "https://example.org/razorpay", events: [.paymentCaptured, .orderPaid], secret: webhookSecret),
    account: account.id)

for try await endpoint in razorpay.webhookEndpoints.list(account: account.id) { print(endpoint.url, endpoint.events) }
```

Free-form sections of an account (`profile`, `legal_info`, `apps`, `brand`, `contact_info`) are ``JSONValue``, because
their shape varies by business type. Webhook URLs must be `https`, and at least one event is required; violations
fail before any request is sent. `WebhookEndpoint.Create` redacts its `secret` from `description` and mirrors.
Document uploads (multipart) stay in `RazorpayLegacy` for now.

## Topics

### Accounts
- ``Account``
- ``RazorpayClient/Accounts``

### Webhook endpoints
- ``WebhookEndpoint``
- ``RazorpayClient/WebhookEndpoints``
