import Foundation
import RazorpayCore

/// A Payment Link: a hosted page that collects one payment. See https://razorpay.com/docs/api/payments/payment-links/.
public struct PaymentLink: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RazorpayID<PaymentLink>

    public let id: ID
    public let amount: Money
    public let amountPaid: Money
    public let status: Status
    public let shortURL: String?
    public let description: String?
    public let referenceID: String?
    public let acceptPartial: Bool
    public let firstMinPartialAmount: Money?
    public let customer: Customer
    public let notify: Notify
    public let reminderEnable: Bool
    public let upiLink: Bool
    public let callbackURL: String?
    public let callbackMethod: String?
    /// Payments made on this link (empty until the first attempt).
    public let payments: [LinkPayment]
    public let notes: Notes
    public let expireBy: Date?
    public let expiredAt: Date?
    public let cancelledAt: Date?
    public let createdAt: Date
    public let updatedAt: Date?

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let created: Self = "created"
        public static let partiallyPaid: Self = "partially_paid"
        public static let paid: Self = "paid"
        public static let expired: Self = "expired"
        public static let cancelled: Self = "cancelled"
    }

    /// Customer details shown on, and used to notify about, the link.
    public struct Customer: Sendable, Hashable, Codable {
        public var name: String?
        public var email: String?
        public var contact: String?
        public init(name: String? = nil, email: String? = nil, contact: String? = nil) {
            self.name = name; self.email = email; self.contact = contact
        }
    }

    /// Which channels Razorpay notifies the customer on.
    public struct Notify: Sendable, Hashable, Codable {
        public var sms: Bool
        public var email: Bool
        public var whatsapp: Bool
        public init(sms: Bool = false, email: Bool = false, whatsapp: Bool = false) {
            self.sms = sms; self.email = email; self.whatsapp = whatsapp
        }
        public init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            sms = try c.decodeFlagIfPresent(.sms) ?? false
            email = try c.decodeFlagIfPresent(.email) ?? false
            whatsapp = try c.decodeFlagIfPresent(.whatsapp) ?? false
        }
        enum CodingKeys: String, CodingKey { case sms, email, whatsapp }
    }

    /// One payment attempt on a link.
    public struct LinkPayment: Sendable, Hashable, Codable {
        public let paymentID: PaymentID
        public let amount: Int
        public let method: String?
        public let status: String?
        public let createdAt: Date?
        public let updatedAt: Date?
        enum CodingKeys: String, CodingKey {
            case amount, method, status, paymentID = "payment_id", createdAt = "created_at", updatedAt = "updated_at"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, amount, currency, status, description, customer, notify, payments, notes
        case amountPaid = "amount_paid", shortURL = "short_url", referenceID = "reference_id"
        case acceptPartial = "accept_partial", firstMinPartialAmount = "first_min_partial_amount"
        case reminderEnable = "reminder_enable", upiLink = "upi_link", callbackURL = "callback_url"
        case callbackMethod = "callback_method", expireBy = "expire_by", expiredAt = "expired_at"
        case cancelledAt = "cancelled_at", createdAt = "created_at", updatedAt = "updated_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
        id = try c.decode(ID.self, forKey: .id)
        amount = try c.decodeMoney(.amount, currency: currency)
        amountPaid = try c.decodeMoneyIfPresent(.amountPaid, currency: currency) ?? Money(amount: 0, currency: currency)
        status = try c.decode(Status.self, forKey: .status)
        shortURL = try c.decodeIfPresent(String.self, forKey: .shortURL)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        referenceID = try c.decodeIfPresent(String.self, forKey: .referenceID).flatMap { $0.isEmpty ? nil : $0 }
        acceptPartial = try c.decodeFlagIfPresent(.acceptPartial) ?? false
        // Razorpay sends 0 when partial payments are off.
        firstMinPartialAmount = try c.decodeMoneyIfPresent(.firstMinPartialAmount, currency: currency).flatMap { $0.amount == 0 ? nil : $0 }
        customer = try c.decodeIfPresent(Customer.self, forKey: .customer) ?? .init()
        notify = try c.decodeIfPresent(Notify.self, forKey: .notify) ?? .init()
        reminderEnable = try c.decodeFlagIfPresent(.reminderEnable) ?? false
        upiLink = try c.decodeFlagIfPresent(.upiLink) ?? false
        callbackURL = try c.decodeIfPresent(String.self, forKey: .callbackURL).flatMap { $0.isEmpty ? nil : $0 }
        callbackMethod = try c.decodeIfPresent(String.self, forKey: .callbackMethod).flatMap { $0.isEmpty ? nil : $0 }
        payments = try c.decodeIfPresent([LinkPayment].self, forKey: .payments) ?? []
        notes = try NotesCoding.decode(c, .notes)
        // 0 means "not set" for these timestamps.
        func date(_ k: CodingKeys) throws -> Date? {
            try c.decodeIfPresent(Date.self, forKey: k).flatMap { $0.timeIntervalSince1970 == 0 ? nil : $0 }
        }
        expireBy = try date(.expireBy)
        expiredAt = try date(.expiredAt)
        cancelledAt = try date(.cancelledAt)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        updatedAt = try date(.updatedAt)
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encodeMoney(amount, .amount)
        try c.encode(amount.currency, forKey: .currency)
        try c.encodeMoney(amountPaid, .amountPaid)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(shortURL, forKey: .shortURL)
        try c.encodeIfPresent(description, forKey: .description)
        try c.encodeIfPresent(referenceID, forKey: .referenceID)
        try c.encode(acceptPartial, forKey: .acceptPartial)
        try c.encodeMoney(firstMinPartialAmount, .firstMinPartialAmount)
        try c.encode(customer, forKey: .customer)
        try c.encode(notify, forKey: .notify)
        try c.encode(reminderEnable, forKey: .reminderEnable)
        try c.encode(upiLink, forKey: .upiLink)
        try c.encodeIfPresent(callbackURL, forKey: .callbackURL)
        try c.encodeIfPresent(callbackMethod, forKey: .callbackMethod)
        try c.encode(payments, forKey: .payments)
        try c.encode(notes, forKey: .notes)
        try c.encodeIfPresent(expireBy, forKey: .expireBy)
        try c.encodeIfPresent(expiredAt, forKey: .expiredAt)
        try c.encodeIfPresent(cancelledAt, forKey: .cancelledAt)
        try c.encode(createdAt, forKey: .createdAt)
        try c.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }

    /// `POST /v1/payment_links`.
    public struct Create: Sendable, Hashable, Encodable {
        public var amount: Money
        public var description: String?
        public var referenceID: String?
        public var customer: Customer?
        public var notify: Notify?
        public var reminderEnable: Bool?
        /// Allow partial payments, optionally with a minimum first payment.
        public var acceptPartial: Bool
        public var firstMinPartialAmount: Money?
        /// Create a UPI-only link.
        public var upiLink: Bool
        public var expireBy: Date?
        public var callbackURL: String?
        public var notes: Notes

        public init(amount: Money, description: String? = nil, referenceID: String? = nil, customer: Customer? = nil,
                    notify: Notify? = nil, reminderEnable: Bool? = nil, acceptPartial: Bool = false,
                    firstMinPartialAmount: Money? = nil, upiLink: Bool = false, expireBy: Date? = nil,
                    callbackURL: String? = nil, notes: Notes = [:]) {
            self.amount = amount; self.description = description; self.referenceID = referenceID
            self.customer = customer; self.notify = notify; self.reminderEnable = reminderEnable
            self.acceptPartial = acceptPartial; self.firstMinPartialAmount = firstMinPartialAmount
            self.upiLink = upiLink; self.expireBy = expireBy; self.callbackURL = callbackURL; self.notes = notes
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeMoney(amount, .amount)
            try c.encode(amount.currency, forKey: .currency)
            try c.encodeIfPresent(description, forKey: .description)
            try c.encodeIfPresent(referenceID, forKey: .referenceID)
            try c.encodeIfPresent(customer, forKey: .customer)
            try c.encodeIfPresent(notify, forKey: .notify)
            try c.encodeIfPresent(reminderEnable, forKey: .reminderEnable)
            if acceptPartial {
                try c.encode(true, forKey: .acceptPartial)
                try c.encodeMoney(firstMinPartialAmount, .firstMinPartialAmount)
            }
            if upiLink { try c.encode(true, forKey: .upiLink) }
            try c.encodeIfPresent(expireBy, forKey: .expireBy)
            if let callbackURL {
                try c.encode(callbackURL, forKey: .callbackURL)
                try c.encode("get", forKey: .callbackMethod)
            }
            try c.encodeNotes(notes, .notes)
        }

        func validate() -> Result<Self, RazorpayError> {
            guard amount.amount > 0 else { return .failure(.invalidRequest("amount must be positive")) }
            if let min = firstMinPartialAmount {
                guard acceptPartial else { return .failure(.invalidRequest("firstMinPartialAmount needs acceptPartial")) }
                guard min.currency == amount.currency, min.amount > 0, min.amount <= amount.amount else {
                    return .failure(.invalidRequest("firstMinPartialAmount must be in (0, amount] and the same currency"))
                }
            }
            return .success(self)
        }
    }

    /// `PATCH /v1/payment_links/:id`. Only set fields change.
    public struct Update: Sendable, Hashable, Encodable {
        public var referenceID: String?
        public var expireBy: Date?
        public var acceptPartial: Bool?
        public var reminderEnable: Bool?
        public var notes: Notes?

        public init(referenceID: String? = nil, expireBy: Date? = nil, acceptPartial: Bool? = nil,
                    reminderEnable: Bool? = nil, notes: Notes? = nil) {
            self.referenceID = referenceID; self.expireBy = expireBy; self.acceptPartial = acceptPartial
            self.reminderEnable = reminderEnable; self.notes = notes
        }

        enum CodingKeys: String, CodingKey {
            case notes, referenceID = "reference_id", expireBy = "expire_by"
            case acceptPartial = "accept_partial", reminderEnable = "reminder_enable"
        }
    }

    /// Where ``RazorpayClient/PaymentLinks/notify(_:via:options:)`` resends the link.
    public struct Medium: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let sms: Self = "sms"
        public static let email: Self = "email"
    }
}

extension PaymentLink: WebhookEntity { public static var payloadKey: String { "payment_link" } }

extension RazorpayWebhook.Name {
    public static let paymentLinkPaid: Self = "payment_link.paid"
    public static let paymentLinkPartiallyPaid: Self = "payment_link.partially_paid"
    public static let paymentLinkExpired: Self = "payment_link.expired"
    public static let paymentLinkCancelled: Self = "payment_link.cancelled"
}

struct PaymentLinkList: Decodable, Sendable {
    let paymentLinks: [PaymentLink]
    enum CodingKeys: String, CodingKey { case paymentLinks = "payment_links" }
    init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        paymentLinks = try c.decodeIfPresent([PaymentLink].self, forKey: .paymentLinks) ?? []
    }
}

/// `{"success": true}`.
public struct SuccessResult: Sendable, Hashable, Codable {
    public let success: Bool
    public init(success: Bool) { self.success = success }
}
