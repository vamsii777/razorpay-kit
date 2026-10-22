import Foundation
import RazorpayCore

/// A Razorpay payment. See https://razorpay.com/docs/api/payments/.
public struct Payment: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = PaymentID

    public let id: ID
    /// Amount and currency.
    public let amount: Money
    public let status: Status
    public let method: Method?
    public let orderID: OrderID?
    public let customerID: CustomerID?
    public let invoiceID: String?
    public let description: String?
    public let international: Bool
    public let captured: Bool
    public let amountRefunded: Money
    public let refundStatus: RefundStatus?
    public let email: String?
    public let contact: String?
    public let bank: String?
    public let wallet: String?
    public let vpa: String?
    public let cardID: String?
    /// Razorpay's fee and the tax on it, when known.
    public let fee: Money?
    public let tax: Money?
    /// Why the payment failed, when ``status`` is ``Status/failed``.
    public let failure: RazorpayError.APIError?
    public let notes: Notes
    public let acquirerData: [String: JSONValue]
    public let createdAt: Date

    /// `created → authorized → captured → refunded`, or `failed`.
    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let created: Self = "created"
        public static let authorized: Self = "authorized"
        public static let captured: Self = "captured"
        public static let refunded: Self = "refunded"
        public static let failed: Self = "failed"
    }

    public struct Method: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let card: Self = "card"
        public static let netbanking: Self = "netbanking"
        public static let wallet: Self = "wallet"
        public static let emi: Self = "emi"
        public static let upi: Self = "upi"
        public static let cardlessEMI: Self = "cardless_emi"
        public static let paylater: Self = "paylater"
        public static let emandate: Self = "emandate"
        public static let nach: Self = "nach"
        public static let bankTransfer: Self = "bank_transfer"
    }

    public struct RefundStatus: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let partial: Self = "partial"
        public static let full: Self = "full"
    }

    enum CodingKeys: String, CodingKey {
        case id, amount, currency, status, method, description, international, captured, email, contact
        case bank, wallet, vpa, fee, tax, notes
        case orderID = "order_id", customerID = "customer_id", invoiceID = "invoice_id", cardID = "card_id"
        case amountRefunded = "amount_refunded", refundStatus = "refund_status", createdAt = "created_at"
        case acquirerData = "acquirer_data"
        case errorCode = "error_code", errorDescription = "error_description", errorSource = "error_source"
        case errorStep = "error_step", errorReason = "error_reason"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decode(Currency.self, forKey: .currency)
        id = try c.decode(ID.self, forKey: .id)
        amount = try c.decodeMoney(.amount, currency: currency)
        status = try c.decode(Status.self, forKey: .status)
        method = try c.decodeIfPresent(Method.self, forKey: .method)
        orderID = try c.decodeIfPresent(OrderID.self, forKey: .orderID)
        customerID = try c.decodeIfPresent(CustomerID.self, forKey: .customerID)
        invoiceID = try c.decodeIfPresent(String.self, forKey: .invoiceID)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        international = try c.decodeIfPresent(Bool.self, forKey: .international) ?? false
        captured = try c.decodeIfPresent(Bool.self, forKey: .captured) ?? (status == .captured)
        amountRefunded = try c.decodeMoneyIfPresent(.amountRefunded, currency: currency) ?? Money(amount: 0, currency: currency)
        refundStatus = try c.decodeIfPresent(RefundStatus.self, forKey: .refundStatus)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        contact = try c.decodeIfPresent(String.self, forKey: .contact)
        bank = try c.decodeIfPresent(String.self, forKey: .bank)
        wallet = try c.decodeIfPresent(String.self, forKey: .wallet)
        vpa = try c.decodeIfPresent(String.self, forKey: .vpa)
        cardID = try c.decodeIfPresent(String.self, forKey: .cardID)
        fee = try c.decodeMoneyIfPresent(.fee, currency: currency)
        tax = try c.decodeMoneyIfPresent(.tax, currency: currency)
        notes = try NotesCoding.decode(c, .notes)
        acquirerData = (try? c.decodeIfPresent([String: JSONValue].self, forKey: .acquirerData)) ?? [:]
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        if let code = try c.decodeIfPresent(String.self, forKey: .errorCode) {
            failure = RazorpayError.APIError(
                code: .init(rawValue: code),
                description: try c.decodeIfPresent(String.self, forKey: .errorDescription) ?? code,
                source: try c.decodeIfPresent(String.self, forKey: .errorSource),
                step: try c.decodeIfPresent(String.self, forKey: .errorStep),
                reason: try c.decodeIfPresent(String.self, forKey: .errorReason))
        } else {
            failure = nil
        }
    }
}

extension Payment: WebhookEntity { public static var payloadKey: String { "payment" } }

extension RazorpayWebhook.Name {
    public static let paymentAuthorized: Self = "payment.authorized"
    public static let paymentCaptured: Self = "payment.captured"
    public static let paymentFailed: Self = "payment.failed"
}
