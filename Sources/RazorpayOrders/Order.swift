import Foundation
import RazorpayCore

/// A Razorpay order. Create one before opening Checkout. See https://razorpay.com/docs/api/orders/.
public struct Order: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = OrderID

    public let id: ID
    public let amount: Money
    public let amountPaid: Money
    public let amountDue: Money
    public let receipt: String?
    public let offerID: String?
    public let status: Status
    public let attempts: Int
    public let notes: Notes
    public let createdAt: Date

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let created: Self = "created"
        public static let attempted: Self = "attempted"
        public static let paid: Self = "paid"
    }

    /// The body for `orders.create(_:options:)`.
    public struct Create: Sendable, Hashable, Encodable {
        public var amount: Money
        public var receipt: String?
        public var notes: Notes
        public var partialPayment: Bool?
        /// Minimum first payment when ``partialPayment`` is `true`.
        public var firstPaymentMinAmount: Int?

        public init(amount: Money, receipt: String? = nil, notes: Notes = [:], partialPayment: Bool? = nil, firstPaymentMinAmount: Int? = nil) {
            self.amount = amount
            self.receipt = receipt
            self.notes = notes
            self.partialPayment = partialPayment
            self.firstPaymentMinAmount = firstPaymentMinAmount
        }

        enum CodingKeys: String, CodingKey {
            case amount, currency, receipt, notes
            case partialPayment = "partial_payment", firstPaymentMinAmount = "first_payment_min_amount"
        }

        public func encode(to encoder: any Encoder) throws {
            guard amount.amount > 0 else {
                throw EncodingError.invalidValue(amount, .init(codingPath: [CodingKeys.amount], debugDescription: "order amount must be positive"))
            }
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(amount.amount, forKey: .amount)
            try c.encode(amount.currency, forKey: .currency)
            try c.encodeIfPresent(receipt, forKey: .receipt)
            if !notes.isEmpty { try c.encode(notes, forKey: .notes) }
            try c.encodeIfPresent(partialPayment, forKey: .partialPayment)
            try c.encodeIfPresent(firstPaymentMinAmount, forKey: .firstPaymentMinAmount)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, amount, currency, receipt, status, attempts, notes
        case amountPaid = "amount_paid", amountDue = "amount_due", offerID = "offer_id", createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decode(Currency.self, forKey: .currency)
        id = try c.decode(ID.self, forKey: .id)
        amount = try c.decodeMoney(.amount, currency: currency)
        amountPaid = try c.decodeMoneyIfPresent(.amountPaid, currency: currency) ?? Money(amount: 0, currency: currency)
        amountDue = try c.decodeMoneyIfPresent(.amountDue, currency: currency) ?? Money(amount: amount.amount - amountPaid.amount, currency: currency)
        receipt = try c.decodeIfPresent(String.self, forKey: .receipt)
        offerID = try c.decodeIfPresent(String.self, forKey: .offerID)
        status = try c.decode(Status.self, forKey: .status)
        attempts = try c.decodeIfPresent(Int.self, forKey: .attempts) ?? 0
        notes = try NotesCoding.decode(c, .notes)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}

extension Order: WebhookEntity { public static var payloadKey: String { "order" } }

extension RazorpayWebhook.Name {
    public static let orderPaid: Self = "order.paid"
}

extension Order {
    /// Encodes Razorpay's wire shape, so a decoded order round-trips.
    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encodeMoney(amount, .amount)
        try c.encode(amount.currency, forKey: .currency)
        try c.encodeMoney(amountPaid, .amountPaid)
        try c.encodeMoney(amountDue, .amountDue)
        try c.encodeIfPresent(receipt, forKey: .receipt)
        try c.encodeIfPresent(offerID, forKey: .offerID)
        try c.encode(status, forKey: .status)
        try c.encode(attempts, forKey: .attempts)
        try c.encode(notes, forKey: .notes)
        try c.encode(createdAt, forKey: .createdAt)
    }
}
