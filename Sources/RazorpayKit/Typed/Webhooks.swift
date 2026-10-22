import Foundation

/// A verified Razorpay webhook, with its entities already decoded.
///
/// ```swift
/// let event = try razorpay.webhooks.verify(request.body, signature: request.headers["X-Razorpay-Signature"])
/// switch event {
/// case .paymentCaptured(let payment): fulfil(payment.orderID)
/// case .orderPaid(let order, _):      markPaid(order.id)
/// case .refundProcessed(let refund):  notify(refund.paymentID)
/// case .unknown(let name, let payload): log(name, payload)
/// default: break
/// }
/// ```
/// See https://razorpay.com/docs/webhooks/payloads/payments/.
public enum WebhookEvent: Sendable, Hashable {
    case paymentAuthorized(Payment)
    case paymentCaptured(Payment)
    case paymentFailed(Payment)
    case orderPaid(Order, Payment)
    case refundCreated(Refund)
    case refundProcessed(Refund)
    case refundFailed(Refund)
    /// An event this SDK does not model yet, with its raw `payload`.
    case unknown(name: String, payload: JSONValue)

    /// The event name, for example `payment.captured`.
    public var name: String {
        switch self {
        case .paymentAuthorized: return "payment.authorized"
        case .paymentCaptured: return "payment.captured"
        case .paymentFailed: return "payment.failed"
        case .orderPaid: return "order.paid"
        case .refundCreated: return "refund.created"
        case .refundProcessed: return "refund.processed"
        case .refundFailed: return "refund.failed"
        case .unknown(let name, _): return name
        }
    }

    /// The payment involved, if any.
    public var payment: Payment? {
        switch self {
        case .paymentAuthorized(let p), .paymentCaptured(let p), .paymentFailed(let p), .orderPaid(_, let p): return p
        default: return nil
        }
    }

    /// Decodes an already verified body.
    static func decode(_ body: [UInt8]) -> Result<WebhookEvent, RazorpayError> {
        do {
            let envelope = try RazorpayCoding.decoder.decode(Envelope.self, from: Data(body))
            func entity<T: Decodable>(_ key: String, _ type: T.Type) throws -> T {
                guard let value = envelope.payload[key]?["entity"] else {
                    throw DecodingError.keyNotFound(AnyKey(key), .init(codingPath: [AnyKey("payload")], debugDescription: "missing \(key).entity"))
                }
                return try value.decode(as: T.self)
            }
            switch envelope.event {
            case "payment.authorized": return .success(.paymentAuthorized(try entity("payment", Payment.self)))
            case "payment.captured": return .success(.paymentCaptured(try entity("payment", Payment.self)))
            case "payment.failed": return .success(.paymentFailed(try entity("payment", Payment.self)))
            case "order.paid": return .success(.orderPaid(try entity("order", Order.self), try entity("payment", Payment.self)))
            case "refund.created": return .success(.refundCreated(try entity("refund", Refund.self)))
            case "refund.processed": return .success(.refundProcessed(try entity("refund", Refund.self)))
            case "refund.failed": return .success(.refundFailed(try entity("refund", Refund.self)))
            default: return .success(.unknown(name: envelope.event, payload: envelope.payloadValue))
            }
        } catch {
            return .failure(.decoding(.init(error, type: WebhookEvent.self, statusCode: nil)))
        }
    }

    private struct Envelope: Decodable {
        let event: String
        let payload: [String: JSONValue]
        var payloadValue: JSONValue { .object(payload) }
        enum CodingKeys: CodingKey { case event, payload }
        init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            event = try c.decode(String.self, forKey: .event)
            payload = try c.decodeIfPresent([String: JSONValue].self, forKey: .payload) ?? [:]
        }
    }

    private struct AnyKey: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init(_ string: String) { stringValue = string }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }
}

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
    public var paymentID: Payment.ID
    /// Set for order payments.
    public var orderID: Order.ID?
    /// Set for subscription payments.
    public var subscriptionID: String?
    public var signature: String

    public init(paymentID: Payment.ID, orderID: Order.ID? = nil, subscriptionID: String? = nil, signature: String) {
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
    public var paymentID: Payment.ID
    public var signature: String

    public init(paymentLinkID: String, referenceID: String, status: String, paymentID: Payment.ID, signature: String) {
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

        func verifyResult(_ body: [UInt8], signature: String?, secret: String?) -> Result<WebhookEvent, RazorpayError> {
            guard let secret = secret ?? signing.webhookSecret, !secret.isEmpty else {
                return .failure(.invalidRequest("no webhook secret: pass webhookSecret to RazorpayClient or secret: to verify"))
            }
            guard let signature, RazorpaySignature.verify(payload: body, signature: signature, secret: secret) else {
                return .failure(.signatureMismatch(.webhook))
            }
            return WebhookEvent.decode(body)
        }
    }

    func verifyResult(_ response: CheckoutResponse) -> Result<Void, RazorpayError> {
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

    func verifyResult(_ callback: PaymentLinkCallback) -> Result<Void, RazorpayError> {
        RazorpaySignature.verifyPaymentLink(paymentLinkID: callback.paymentLinkID, referenceID: callback.referenceID, status: callback.status,
                                            paymentID: callback.paymentID.rawValue, signature: callback.signature, secret: signing.keySecret)
            ? .success(()) : .failure(.signatureMismatch(.paymentLink))
    }
}

#if compiler(>=6.0)
extension RazorpayClient.Webhooks {
    /// Verifies the `X-Razorpay-Signature` over the **raw** body, then decodes the event.
    ///
    /// - Parameters:
    ///   - body: The exact bytes received. Do not re-encode the JSON first.
    ///   - signature: The header value. `nil` (header missing) fails as a mismatch.
    ///   - secret: Overrides the client's `webhookSecret`.
    /// - Throws: ``RazorpayError/signatureMismatch(_:)``, ``RazorpayError/decoding(_:)`` for a
    ///   verified but unreadable body, or ``RazorpayError/invalidRequest(_:)`` without a secret.
    public func verify(_ body: some DataProtocol, signature: String?, secret: String? = nil) throws(RazorpayError) -> WebhookEvent {
        try verifyResult(Array(body), signature: signature, secret: secret).get()
    }

    /// Verifies a body you already have as a string (its UTF-8 bytes).
    public func verify(_ body: String, signature: String?, secret: String? = nil) throws(RazorpayError) -> WebhookEvent {
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
    /// Verifies the `X-Razorpay-Signature` over the **raw** body, then decodes the event.
    public func verify(_ body: some DataProtocol, signature: String?, secret: String? = nil) throws -> WebhookEvent {
        try verifyResult(Array(body), signature: signature, secret: secret).get()
    }

    /// Verifies a body you already have as a string (its UTF-8 bytes).
    public func verify(_ body: String, signature: String?, secret: String? = nil) throws -> WebhookEvent {
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
