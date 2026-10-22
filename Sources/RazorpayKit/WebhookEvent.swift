import Foundation
import RazorpayCore
import RazorpayPayments
import RazorpayOrders
import RazorpayRefunds

/// Every webhook this SDK models, as one exhaustive enum. Available with `import RazorpayKit`.
///
/// ```swift
/// switch try razorpay.webhooks.verify(body, signature: header).event {
/// case .paymentCaptured(let payment): fulfil(payment.orderID)
/// case .orderPaid(let order, _):      markPaid(order.id)
/// case .unknown(let name, let payload): log(name, payload)
/// default: break
/// }
/// ```
public enum WebhookEvent: Sendable, Hashable {
    case paymentAuthorized(Payment)
    case paymentCaptured(Payment)
    case paymentFailed(Payment)
    case orderPaid(Order, Payment)
    case refundCreated(Refund)
    case refundProcessed(Refund)
    case refundFailed(Refund)
    case downtimeStarted(Downtime)
    case downtimeUpdated(Downtime)
    case downtimeResolved(Downtime)
    /// An event this SDK does not model yet, with its raw `payload`.
    case unknown(name: String, payload: JSONValue)

    /// The event name, for example `payment.captured`.
    public var name: String {
        switch self {
        case .paymentAuthorized: return RazorpayWebhook.Name.paymentAuthorized.rawValue
        case .paymentCaptured: return RazorpayWebhook.Name.paymentCaptured.rawValue
        case .paymentFailed: return RazorpayWebhook.Name.paymentFailed.rawValue
        case .orderPaid: return RazorpayWebhook.Name.orderPaid.rawValue
        case .refundCreated: return RazorpayWebhook.Name.refundCreated.rawValue
        case .refundProcessed: return RazorpayWebhook.Name.refundProcessed.rawValue
        case .refundFailed: return RazorpayWebhook.Name.refundFailed.rawValue
        case .downtimeStarted: return RazorpayWebhook.Name.downtimeStarted.rawValue
        case .downtimeUpdated: return RazorpayWebhook.Name.downtimeUpdated.rawValue
        case .downtimeResolved: return RazorpayWebhook.Name.downtimeResolved.rawValue
        case .unknown(let name, _): return name
        }
    }

    /// The downtime involved, if any.
    public var downtime: Downtime? {
        switch self {
        case .downtimeStarted(let d), .downtimeUpdated(let d), .downtimeResolved(let d): return d
        default: return nil
        }
    }

    /// The payment involved, if any.
    public var payment: Payment? {
        switch self {
        case .paymentAuthorized(let p), .paymentCaptured(let p), .paymentFailed(let p), .orderPaid(_, let p): return p
        default: return nil
        }
    }

    /// Maps a verified envelope to a typed event.
    public init(_ webhook: RazorpayWebhook) throws {
        self = try Self.result(webhook).get()
    }

    static func result(_ w: RazorpayWebhook) -> Result<WebhookEvent, RazorpayError> {
        func e<T: WebhookEntity>(_ t: T.Type) -> Result<T, RazorpayError> { w.entityResult(t) }
        switch w.name {
        case .paymentAuthorized: return e(Payment.self).map(Self.paymentAuthorized)
        case .paymentCaptured: return e(Payment.self).map(Self.paymentCaptured)
        case .paymentFailed: return e(Payment.self).map(Self.paymentFailed)
        case .orderPaid: return e(Order.self).flatMap { order in e(Payment.self).map { .orderPaid(order, $0) } }
        case .refundCreated: return e(Refund.self).map(Self.refundCreated)
        case .refundProcessed: return e(Refund.self).map(Self.refundProcessed)
        case .refundFailed: return e(Refund.self).map(Self.refundFailed)
        case .downtimeStarted: return e(Downtime.self).map(Self.downtimeStarted)
        case .downtimeUpdated: return e(Downtime.self).map(Self.downtimeUpdated)
        case .downtimeResolved: return e(Downtime.self).map(Self.downtimeResolved)
        default: return .success(.unknown(name: w.name.rawValue, payload: w.payload))
        }
    }
}

extension RazorpayWebhook {
    #if compiler(>=6.0)
    /// The typed ``WebhookEvent`` for this envelope.
    public var event: WebhookEvent { get throws(RazorpayError) { try WebhookEvent.result(self).get() } }
    #else
    /// The typed ``WebhookEvent`` for this envelope.
    public var event: WebhookEvent { get throws { try WebhookEvent.result(self).get() } }
    #endif
}
