import Foundation
import RazorpayCore

/// A refund of a captured payment. See https://razorpay.com/docs/api/refunds/.
public struct Refund: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RefundID

    public let id: ID
    public let amount: Money
    public let paymentID: PaymentID
    public let status: Status
    public let receipt: String?
    public let batchID: String?
    public let speedRequested: Speed?
    public let speedProcessed: Speed?
    public let notes: Notes
    public let acquirerData: [String: JSONValue]
    public let createdAt: Date

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let pending: Self = "pending"
        public static let processed: Self = "processed"
        public static let failed: Self = "failed"
    }

    public struct Speed: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let normal: Self = "normal"
        public static let optimum: Self = "optimum"
        public static let instant: Self = "instant"
    }

    /// The body for `payments.refund(_:_:options:)`.
    public struct Create: Sendable, Hashable, Encodable {
        /// Amount in minor units. `nil` refunds the full remaining amount.
        public var amount: Int?
        public var speed: Speed?
        public var receipt: String?
        public var notes: Notes

        public init(amount: Int? = nil, speed: Speed? = nil, receipt: String? = nil, notes: Notes = [:]) {
            self.amount = amount
            self.speed = speed
            self.receipt = receipt
            self.notes = notes
        }

        /// A full refund.
        public static var full: Create { Create() }
        /// A partial refund of `amount`.
        public static func partial(_ amount: Money, speed: Speed? = nil) -> Create { Create(amount: amount.amount, speed: speed) }

        enum CodingKeys: CodingKey { case amount, speed, receipt, notes }
        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeIfPresent(amount, forKey: .amount)
            try c.encodeIfPresent(speed, forKey: .speed)
            try c.encodeIfPresent(receipt, forKey: .receipt)
            if !notes.isEmpty { try c.encode(notes, forKey: .notes) }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, amount, currency, status, receipt, notes
        case paymentID = "payment_id", batchID = "batch_id", createdAt = "created_at", acquirerData = "acquirer_data"
        case speedRequested = "speed_requested", speedProcessed = "speed_processed"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
        id = try c.decode(ID.self, forKey: .id)
        amount = try c.decodeMoney(.amount, currency: currency)
        paymentID = try c.decode(PaymentID.self, forKey: .paymentID)
        status = try c.decodeIfPresent(Status.self, forKey: .status) ?? .pending
        receipt = try c.decodeIfPresent(String.self, forKey: .receipt)
        batchID = try c.decodeIfPresent(String.self, forKey: .batchID)
        speedRequested = try c.decodeIfPresent(Speed.self, forKey: .speedRequested)
        speedProcessed = try c.decodeIfPresent(Speed.self, forKey: .speedProcessed)
        notes = try NotesCoding.decode(c, .notes)
        acquirerData = (try? c.decodeIfPresent([String: JSONValue].self, forKey: .acquirerData)) ?? [:]
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}

extension Refund: WebhookEntity { public static var payloadKey: String { "refund" } }

extension RazorpayWebhook.Name {
    public static let refundCreated: Self = "refund.created"
    public static let refundProcessed: Self = "refund.processed"
    public static let refundFailed: Self = "refund.failed"
}

extension Refund {
    /// Encodes Razorpay's wire shape, so a decoded refund round-trips.
    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encodeMoney(amount, .amount)
        try c.encode(amount.currency, forKey: .currency)
        try c.encode(paymentID, forKey: .paymentID)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(receipt, forKey: .receipt)
        try c.encodeIfPresent(batchID, forKey: .batchID)
        try c.encodeIfPresent(speedRequested, forKey: .speedRequested)
        try c.encodeIfPresent(speedProcessed, forKey: .speedProcessed)
        try c.encode(notes, forKey: .notes)
        try c.encode(acquirerData, forKey: .acquirerData)
        try c.encode(createdAt, forKey: .createdAt)
    }
}
