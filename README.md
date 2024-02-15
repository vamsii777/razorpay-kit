# RazorpayKit
![](https://img.shields.io/badge/Swift-5.9-green.svg?style=svg)
![](https://img.shields.io/badge/SwiftNio-2-orange.svg?style=svg)

RazorpayKit is a Swift library for integrating with Razorpay's payment gateway. It supports managing orders, payments, subscriptions, webhooks and more.

## Installation

### Swift Package Manager

You can add RazorpayKit to your project via Swift Package Manager (SPM) by adding the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/vamsii777/RazorpayKit.git", from: "0.0.8")
]
```


## Using the API

Initialize the `RazorpayClient` with your Razorpay API key, secret, and environment. This client will be your gateway to interacting with the Razorpay API.


```swift
let httpClient = HTTPClient(...)
let razorpay = RazorpayClient(httpClient: httpClient, key: "rzp_test_12345", secret: "your_secret", environment: .production)
```

And now you have access to the APIs via `razorpay`.

The APIs you have available correspond to what's implemented.

For example to use the `orders` API, the razorpayClient has a property to access that API via routes.

#### Creating an Order

```swift
let orderData = [
    "amount": 50000, // Specify amount in the smallest currency unit.
    "currency": "INR",
    "receipt": "order_rcptid_11"
]

let order = try await razorpayClient.order.create(data: orderData)
print("Created Order: \(order)")
```

#### Fetching a Payment

```swift
let paymentId = "pay_29QQoUBi66xm2f"
let payment = try await razorpayClient.payment.fetch(paymentID: paymentId)
print("Fetched Payment: \(payment)")
```

#### Managing Subscriptions

```swift
let subscriptionId = "sub_00000000000001"
let subscription = try await razorpayClient.subscription.fetch(subscriptionID: subscriptionId)
print("Fetched Subscription: \(subscription)")
```

## What's Implemented

### Core Resources
* [x] **Accounts**
* [x] **Addons**
* [x] **Cards**
* [x] **Customers**
* [x] **Fund Accounts**
* [x] **IIN (Issuer Identification Number)**
* [x] **Invoices**
* [x] **Items**
* [x] **Orders**
* [x] **Payments**
* [x] **Payment Links**
* [x] **Products**
* [x] **QR Codes**
* [x] **Refunds**
* [x] **Settlements**
* [x] **Stakeholders**
* [x] **Subscriptions**
* [x] **Tokens**
* [x] **Transfers**
* [x] **Virtual Accounts**
* [x] **Webhooks**

### Additional Features
* [x] **Authentication**: Securely authenticate using your Razorpay key and secret.
* [x] **Headers Management**: Customize request headers for special use cases such as idempotent requests.
* [x] **Asynchronous API Calls**: Support for Swift's modern async/await pattern for clean and simple asynchronous API calls.


## LICENSE
RazorpayKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.