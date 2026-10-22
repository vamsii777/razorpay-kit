import Foundation
import RazorpayCore

/// The fields Checkout hands your front end after a successful payment.
///
/// It decodes straight from Checkout's JSON or form fields (`razorpay_payment_id`, …):
///
/// ```swift
/// let response = try JSONDecoder().decode(CheckoutResponse.self, from: body)
/// try razorpay.verify(response)
/// ```
/// See https://razorpay.com/docs/payments/payment-gateway/web-integration/standard/build-integration/#verify-payment-signature.
public struct CheckoutResponse: Sendable, Hashable, Codable {
    public var paymentID: PaymentID
    /// Set for order payments.
    public var orderID: OrderID?
    /// Set for subscription payments.
    public var subscriptionID: String?
    public var signature: String

    public init(paymentID: PaymentID, orderID: OrderID? = nil, subscriptionID: String? = nil, signature: String) {
        self.paymentID = paymentID
        self.orderID = orderID
        self.subscriptionID = subscriptionID
        self.signature = signature
    }

    enum CodingKeys: String, CodingKey {
        case paymentID = "razorpay_payment_id", orderID = "razorpay_order_id"
        case subscriptionID = "razorpay_subscription_id", signature = "razorpay_signature"
    }
}

/// The query parameters Razorpay appends to a Payment Link's callback URL.
/// See https://razorpay.com/docs/payments/payment-links/apis/#verify-signature.
public struct PaymentLinkCallback: Sendable, Hashable, Codable {
    public var paymentLinkID: String
    public var referenceID: String
    public var status: String
    public var paymentID: PaymentID
    public var signature: String

    public init(paymentLinkID: String, referenceID: String, status: String, paymentID: PaymentID, signature: String) {
        self.paymentLinkID = paymentLinkID
        self.referenceID = referenceID
        self.status = status
        self.paymentID = paymentID
        self.signature = signature
    }

    enum CodingKeys: String, CodingKey {
        case paymentLinkID = "razorpay_payment_link_id", referenceID = "razorpay_payment_link_reference_id"
        case status = "razorpay_payment_link_status", paymentID = "razorpay_payment_id", signature = "razorpay_signature"
    }
}

extension RazorpayClient {
    /// Webhook verification. Needs `webhookSecret` on the client (or pass `secret:`).
    public var webhooks: Webhooks { Webhooks(signing: signing) }

    /// See ``RazorpayClient/webhooks``.
    public struct Webhooks: Sendable {
        let signing: SigningSecrets

        package func verifyResult(_ body: [UInt8], signature: String?, secret: String?) -> Result<RazorpayWebhook, RazorpayError> {
            guard let secret = secret ?? signing.webhookSecret, !secret.isEmpty else {
                return .failure(.invalidRequest("no webhook secret: pass webhookSecret to RazorpayClient or secret: to verify"))
            }
            guard let signature, RazorpaySignature.verify(payload: body, signature: signature, secret: secret) else {
                return .failure(.signatureMismatch(.webhook))
            }
            return RazorpayWebhook.decode(body)
        }
    }

    package func verifyResult(_ response: CheckoutResponse) -> Result<Void, RazorpayError> {
        let secret = signing.keySecret
        if let orderID = response.orderID {
            return RazorpaySignature.verifyPayment(orderID: orderID.rawValue, paymentID: response.paymentID.rawValue, signature: response.signature, secret: secret)
                ? .success(()) : .failure(.signatureMismatch(.payment))
        }
        if let subscriptionID = response.subscriptionID {
            return RazorpaySignature.verifySubscription(paymentID: response.paymentID.rawValue, subscriptionID: subscriptionID, signature: response.signature, secret: secret)
                ? .success(()) : .failure(.signatureMismatch(.subscription))
        }
        return .failure(.invalidRequest("CheckoutResponse needs an orderID or a subscriptionID"))
    }

    package func verifyResult(_ callback: PaymentLinkCallback) -> Result<Void, RazorpayError> {
        RazorpaySignature.verifyPaymentLink(paymentLinkID: callback.paymentLinkID, referenceID: callback.referenceID, status: callback.status,
                                            paymentID: callback.paymentID.rawValue, signature: callback.signature, secret: signing.keySecret)
            ? .success(()) : .failure(.signatureMismatch(.paymentLink))
    }
}

#if compiler(>=6.0)
extension RazorpayClient.Webhooks {
    /// Verifies the `X-Razorpay-Signature` over the **raw** body, then decodes the envelope.
    ///
    /// - Parameters:
    ///   - body: The exact bytes received. Do not re-encode the JSON first.
    ///   - signature: The header value. `nil` (header missing) fails as a mismatch.
    ///   - secret: Overrides the client's `webhookSecret`.
    public func verify(_ body: some DataProtocol, signature: String?, secret: String? = nil) throws(RazorpayError) -> RazorpayWebhook {
        try verifyResult(Array(body), signature: signature, secret: secret).get()
    }

    /// Verifies a body you already have as a string (its UTF-8 bytes).
    public func verify(_ body: String, signature: String?, secret: String? = nil) throws(RazorpayError) -> RazorpayWebhook {
        try verifyResult(Array(body.utf8), signature: signature, secret: secret).get()
    }
}

extension RazorpayClient {
    /// Verifies a Checkout payment or subscription signature with your key secret.
    public func verify(_ response: CheckoutResponse) throws(RazorpayError) {
        try verifyResult(response).get()
    }

    /// Verifies a Payment Link callback signature with your key secret.
    public func verify(_ callback: PaymentLinkCallback) throws(RazorpayError) {
        try verifyResult(callback).get()
    }
}
#else
extension RazorpayClient.Webhooks {
    /// Verifies the `X-Razorpay-Signature` over the **raw** body, then decodes the envelope.
    public func verify(_ body: some DataProtocol, signature: String?, secret: String? = nil) throws -> RazorpayWebhook {
        try verifyResult(Array(body), signature: signature, secret: secret).get()
    }

    /// Verifies a body you already have as a string (its UTF-8 bytes).
    public func verify(_ body: String, signature: String?, secret: String? = nil) throws -> RazorpayWebhook {
        try verifyResult(Array(body.utf8), signature: signature, secret: secret).get()
    }
}

extension RazorpayClient {
    /// Verifies a Checkout payment or subscription signature with your key secret.
    public func verify(_ response: CheckoutResponse) throws {
        try verifyResult(response).get()
    }

    /// Verifies a Payment Link callback signature with your key secret.
    public func verify(_ callback: PaymentLinkCallback) throws {
        try verifyResult(callback).get()
    }
}
#endif
