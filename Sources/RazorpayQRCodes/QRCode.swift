import Foundation
import RazorpayCore

/// A UPI or Bharat QR code. Amounts are always INR. See https://razorpay.com/docs/api/qr-codes/.
public struct QRCode: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RazorpayID<QRCode>

    public let id: ID
    public let name: String?
    public let type: Kind
    public let usage: Usage
    public let status: Status
    public let imageURL: String?
    public let description: String?
    public let fixedAmount: Bool
    /// The amount to pay, when ``fixedAmount`` is `true`.
    public let paymentAmount: Money?
    public let paymentsAmountReceived: Money
    public let paymentsCountReceived: Int
    public let customerID: CustomerID?
    public let notes: Notes
    public let closeBy: Date?
    public let closedAt: Date?
    public let closeReason: CloseReason?
    public let createdAt: Date

    public struct Kind: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let upi: Self = "upi_qr"
        public static let bharat: Self = "bharat_qr"
    }

    public struct Usage: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let singleUse: Self = "single_use"
        public static let multipleUse: Self = "multiple_use"
    }

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let active: Self = "active"
        public static let closed: Self = "closed"
    }

    public struct CloseReason: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let onDemand: Self = "on_demand"
        public static let paid: Self = "paid"
        public static let expired: Self = "expired"
    }

    enum CodingKeys: String, CodingKey {
        case id, name, type, usage, status, description, notes
        case imageURL = "image_url", fixedAmount = "fixed_amount", paymentAmount = "payment_amount"
        case paymentsAmountReceived = "payments_amount_received", paymentsCountReceived = "payments_count_received"
        case customerID = "customer_id", closeBy = "close_by", closedAt = "closed_at"
        case closeReason = "close_reason", createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        type = try c.decode(Kind.self, forKey: .type)
        usage = try c.decode(Usage.self, forKey: .usage)
        status = try c.decode(Status.self, forKey: .status)
        imageURL = try c.decodeIfPresent(String.self, forKey: .imageURL)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        fixedAmount = try c.decodeFlagIfPresent(.fixedAmount) ?? false
        paymentAmount = try c.decodeMoneyIfPresent(.paymentAmount, currency: .inr)
        paymentsAmountReceived = try c.decodeMoneyIfPresent(.paymentsAmountReceived, currency: .inr) ?? .inr(paise: 0)
        paymentsCountReceived = try c.decodeIfPresent(Int.self, forKey: .paymentsCountReceived) ?? 0
        customerID = try c.decodeIfPresent(CustomerID.self, forKey: .customerID)
        notes = try NotesCoding.decode(c, .notes)
        closeBy = try c.decodeIfPresent(Date.self, forKey: .closeBy)
        closedAt = try c.decodeIfPresent(Date.self, forKey: .closedAt)
        closeReason = try c.decodeIfPresent(CloseReason.self, forKey: .closeReason)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encodeIfPresent(name, forKey: .name)
        try c.encode(type, forKey: .type)
        try c.encode(usage, forKey: .usage)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(imageURL, forKey: .imageURL)
        try c.encodeIfPresent(description, forKey: .description)
        try c.encode(fixedAmount, forKey: .fixedAmount)
        try c.encodeMoney(paymentAmount, .paymentAmount)
        try c.encodeMoney(paymentsAmountReceived, .paymentsAmountReceived)
        try c.encode(paymentsCountReceived, forKey: .paymentsCountReceived)
        try c.encodeIfPresent(customerID, forKey: .customerID)
        try c.encode(notes, forKey: .notes)
        try c.encodeIfPresent(closeBy, forKey: .closeBy)
        try c.encodeIfPresent(closedAt, forKey: .closedAt)
        try c.encodeIfPresent(closeReason, forKey: .closeReason)
        try c.encode(createdAt, forKey: .createdAt)
    }

    /// `POST /v1/payments/qr_codes`.
    public struct Create: Sendable, Hashable, Encodable {
        public var type: Kind
        public var usage: Usage
        public var name: String?
        public var description: String?
        /// Set to require this exact amount (INR). `nil` lets the customer choose.
        public var paymentAmount: Money?
        public var customerID: CustomerID?
        public var closeBy: Date?
        public var notes: Notes

        public init(type: Kind = .upi, usage: Usage, name: String? = nil, description: String? = nil,
                    paymentAmount: Money? = nil, customerID: CustomerID? = nil, closeBy: Date? = nil, notes: Notes = [:]) {
            self.type = type; self.usage = usage; self.name = name; self.description = description
            self.paymentAmount = paymentAmount; self.customerID = customerID; self.closeBy = closeBy; self.notes = notes
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(type, forKey: .type)
            try c.encode(usage, forKey: .usage)
            try c.encodeIfPresent(name, forKey: .name)
            try c.encodeIfPresent(description, forKey: .description)
            try c.encode(paymentAmount != nil, forKey: .fixedAmount)
            try c.encodeMoney(paymentAmount, .paymentAmount)
            try c.encodeIfPresent(customerID, forKey: .customerID)
            try c.encodeIfPresent(closeBy, forKey: .closeBy)
            try c.encodeNotes(notes, .notes)
        }

        func validate() -> Result<Self, RazorpayError> {
            if let amount = paymentAmount {
                guard amount.currency == .inr else { return .failure(.invalidRequest("QR codes accept INR only")) }
                guard amount.amount > 0 else { return .failure(.invalidRequest("paymentAmount must be positive")) }
            }
            if usage == .singleUse, paymentAmount == nil {
                return .failure(.invalidRequest("single-use QR codes need a paymentAmount"))
            }
            return .success(self)
        }
    }
}

extension QRCode: WebhookEntity { public static var payloadKey: String { "qr_code" } }

extension RazorpayWebhook.Name {
    public static let qrCodeCredited: Self = "qr_code.credited"
    public static let qrCodeClosed: Self = "qr_code.closed"
}
