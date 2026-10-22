import Foundation
import RazorpayCore
import RazorpayPayments
import RazorpayOrders
import RazorpayRefunds
import RazorpayTokens
import RazorpayPaymentLinks
import RazorpayQRCodes
import RazorpayRoute
import RazorpaySmartCollect

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
    case tokenConfirmed(Token)
    case tokenRejected(Token)
    case tokenPaused(Token)
    case tokenCancelled(Token)
    /// The link, and the payment that paid it when the payload includes one.
    case paymentLinkPaid(PaymentLink, Payment?)
    case paymentLinkPartiallyPaid(PaymentLink, Payment?)
    case paymentLinkExpired(PaymentLink)
    case paymentLinkCancelled(PaymentLink)
    case qrCodeCredited(QRCode, Payment?)
    case qrCodeClosed(QRCode)
    case transferProcessed(Transfer)
    case transferFailed(Transfer)
    case transferReversed(Transfer)
    case virtualAccountCreated(VirtualAccount)
    case virtualAccountCredited(VirtualAccount, Payment?, BankTransfer?)
    case virtualAccountClosed(VirtualAccount)
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
        case .tokenConfirmed: return RazorpayWebhook.Name.tokenConfirmed.rawValue
        case .tokenRejected: return RazorpayWebhook.Name.tokenRejected.rawValue
        case .tokenPaused: return RazorpayWebhook.Name.tokenPaused.rawValue
        case .tokenCancelled: return RazorpayWebhook.Name.tokenCancelled.rawValue
        case .paymentLinkPaid: return RazorpayWebhook.Name.paymentLinkPaid.rawValue
        case .paymentLinkPartiallyPaid: return RazorpayWebhook.Name.paymentLinkPartiallyPaid.rawValue
        case .paymentLinkExpired: return RazorpayWebhook.Name.paymentLinkExpired.rawValue
        case .paymentLinkCancelled: return RazorpayWebhook.Name.paymentLinkCancelled.rawValue
        case .qrCodeCredited: return RazorpayWebhook.Name.qrCodeCredited.rawValue
        case .qrCodeClosed: return RazorpayWebhook.Name.qrCodeClosed.rawValue
        case .transferProcessed: return RazorpayWebhook.Name.transferProcessed.rawValue
        case .transferFailed: return RazorpayWebhook.Name.transferFailed.rawValue
        case .transferReversed: return RazorpayWebhook.Name.transferReversed.rawValue
        case .virtualAccountCreated: return RazorpayWebhook.Name.virtualAccountCreated.rawValue
        case .virtualAccountCredited: return RazorpayWebhook.Name.virtualAccountCredited.rawValue
        case .virtualAccountClosed: return RazorpayWebhook.Name.virtualAccountClosed.rawValue
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
        case .paymentLinkPaid(_, let p), .paymentLinkPartiallyPaid(_, let p), .qrCodeCredited(_, let p), .virtualAccountCredited(_, let p, _): return p
        default: return nil
        }
    }

    /// Maps a verified envelope to a typed event.
    public init(_ webhook: RazorpayWebhook) throws {
        self = try Self.result(webhook).get()
    }

    static func result(_ w: RazorpayWebhook) -> Result<WebhookEvent, RazorpayError> {
        func e<T: WebhookEntity>(_ t: T.Type) -> Result<T, RazorpayError> { w.entityResult(t) }
        func o<T: WebhookEntity>(_ t: T.Type) -> Result<T?, RazorpayError> { w.has(t) ? w.entityResult(t).map { $0 } : .success(nil) }
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
        case .tokenConfirmed: return e(Token.self).map(Self.tokenConfirmed)
        case .tokenRejected: return e(Token.self).map(Self.tokenRejected)
        case .tokenPaused: return e(Token.self).map(Self.tokenPaused)
        case .tokenCancelled: return e(Token.self).map(Self.tokenCancelled)
        case .paymentLinkPaid: return e(PaymentLink.self).flatMap { l in o(Payment.self).map { .paymentLinkPaid(l, $0) } }
        case .paymentLinkPartiallyPaid: return e(PaymentLink.self).flatMap { l in o(Payment.self).map { .paymentLinkPartiallyPaid(l, $0) } }
        case .paymentLinkExpired: return e(PaymentLink.self).map(Self.paymentLinkExpired)
        case .paymentLinkCancelled: return e(PaymentLink.self).map(Self.paymentLinkCancelled)
        case .qrCodeCredited: return e(QRCode.self).flatMap { q in o(Payment.self).map { .qrCodeCredited(q, $0) } }
        case .qrCodeClosed: return e(QRCode.self).map(Self.qrCodeClosed)
        case .transferProcessed: return e(Transfer.self).map(Self.transferProcessed)
        case .transferFailed: return e(Transfer.self).map(Self.transferFailed)
        case .transferReversed: return e(Transfer.self).map(Self.transferReversed)
        case .virtualAccountCreated: return e(VirtualAccount.self).map(Self.virtualAccountCreated)
        case .virtualAccountCredited:
            return e(VirtualAccount.self).flatMap { va in o(Payment.self).flatMap { p in o(BankTransfer.self).map { .virtualAccountCredited(va, p, $0) } } }
        case .virtualAccountClosed: return e(VirtualAccount.self).map(Self.virtualAccountClosed)
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
