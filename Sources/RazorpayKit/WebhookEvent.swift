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
import RazorpaySubscriptions
import RazorpayInvoices
import RazorpaySettlements

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
    case subscriptionAuthenticated(Subscription, Payment?)
    case subscriptionActivated(Subscription, Payment?)
    case subscriptionCharged(Subscription, Payment?)
    case subscriptionCompleted(Subscription, Payment?)
    case subscriptionUpdated(Subscription, Payment?)
    case subscriptionPending(Subscription, Payment?)
    case subscriptionHalted(Subscription, Payment?)
    case subscriptionCancelled(Subscription, Payment?)
    case subscriptionPaused(Subscription, Payment?)
    case subscriptionResumed(Subscription, Payment?)
    case invoicePaid(Invoice, Payment?)
    case invoicePartiallyPaid(Invoice, Payment?)
    case invoiceExpired(Invoice)
    case settlementProcessed(Settlement)
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
        case .subscriptionAuthenticated: return RazorpayWebhook.Name.subscriptionAuthenticated.rawValue
        case .subscriptionActivated: return RazorpayWebhook.Name.subscriptionActivated.rawValue
        case .subscriptionCharged: return RazorpayWebhook.Name.subscriptionCharged.rawValue
        case .subscriptionCompleted: return RazorpayWebhook.Name.subscriptionCompleted.rawValue
        case .subscriptionUpdated: return RazorpayWebhook.Name.subscriptionUpdated.rawValue
        case .subscriptionPending: return RazorpayWebhook.Name.subscriptionPending.rawValue
        case .subscriptionHalted: return RazorpayWebhook.Name.subscriptionHalted.rawValue
        case .subscriptionCancelled: return RazorpayWebhook.Name.subscriptionCancelled.rawValue
        case .subscriptionPaused: return RazorpayWebhook.Name.subscriptionPaused.rawValue
        case .subscriptionResumed: return RazorpayWebhook.Name.subscriptionResumed.rawValue
        case .invoicePaid: return RazorpayWebhook.Name.invoicePaid.rawValue
        case .invoicePartiallyPaid: return RazorpayWebhook.Name.invoicePartiallyPaid.rawValue
        case .invoiceExpired: return RazorpayWebhook.Name.invoiceExpired.rawValue
        case .settlementProcessed: return RazorpayWebhook.Name.settlementProcessed.rawValue
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
        case .paymentLinkPaid(_, let p), .paymentLinkPartiallyPaid(_, let p), .qrCodeCredited(_, let p), .virtualAccountCredited(_, let p, _), .subscriptionAuthenticated(_, let p), .subscriptionActivated(_, let p), .subscriptionCharged(_, let p), .subscriptionCompleted(_, let p), .subscriptionUpdated(_, let p), .subscriptionPending(_, let p), .subscriptionHalted(_, let p), .subscriptionCancelled(_, let p), .subscriptionPaused(_, let p), .subscriptionResumed(_, let p), .invoicePaid(_, let p), .invoicePartiallyPaid(_, let p): return p
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
        case .subscriptionAuthenticated: return e(Subscription.self).flatMap { s in o(Payment.self).map { .subscriptionAuthenticated(s, $0) } }
        case .subscriptionActivated: return e(Subscription.self).flatMap { s in o(Payment.self).map { .subscriptionActivated(s, $0) } }
        case .subscriptionCharged: return e(Subscription.self).flatMap { s in o(Payment.self).map { .subscriptionCharged(s, $0) } }
        case .subscriptionCompleted: return e(Subscription.self).flatMap { s in o(Payment.self).map { .subscriptionCompleted(s, $0) } }
        case .subscriptionUpdated: return e(Subscription.self).flatMap { s in o(Payment.self).map { .subscriptionUpdated(s, $0) } }
        case .subscriptionPending: return e(Subscription.self).flatMap { s in o(Payment.self).map { .subscriptionPending(s, $0) } }
        case .subscriptionHalted: return e(Subscription.self).flatMap { s in o(Payment.self).map { .subscriptionHalted(s, $0) } }
        case .subscriptionCancelled: return e(Subscription.self).flatMap { s in o(Payment.self).map { .subscriptionCancelled(s, $0) } }
        case .subscriptionPaused: return e(Subscription.self).flatMap { s in o(Payment.self).map { .subscriptionPaused(s, $0) } }
        case .subscriptionResumed: return e(Subscription.self).flatMap { s in o(Payment.self).map { .subscriptionResumed(s, $0) } }
        case .invoicePaid: return e(Invoice.self).flatMap { i in o(Payment.self).map { .invoicePaid(i, $0) } }
        case .invoicePartiallyPaid: return e(Invoice.self).flatMap { i in o(Payment.self).map { .invoicePartiallyPaid(i, $0) } }
        case .invoiceExpired: return e(Invoice.self).map(Self.invoiceExpired)
        case .settlementProcessed: return e(Settlement.self).map(Self.settlementProcessed)
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
