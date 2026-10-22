import Foundation
import RazorpayCore

/// A reusable product or service you bill for in invoices, plans and add-ons.
/// See https://razorpay.com/docs/api/payments/items/.
public struct Item: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = ItemID

    public let id: ID
    public let active: Bool
    public let name: String
    public let description: String?
    /// The price, in the item's currency.
    public let amount: Money
    /// The per-unit price. Razorpay sends it for plan and add-on items.
    public let unitAmount: Money?
    public let type: Kind?
    public let unit: String?
    public let taxInclusive: Bool?
    public let hsnCode: String?
    public let sacCode: String?
    public let taxRate: Double?
    public let taxID: String?
    public let taxGroupID: String?
    public let createdAt: Date?
    public let updatedAt: Date?

    /// What the item is used for.
    public struct Kind: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let invoice: Self = "invoice"
        public static let plan: Self = "plan"
        public static let addon: Self = "addon"
    }

    /// The body for ``RazorpayClient/Items/create(_:options:)``.
    public struct Create: Sendable, Hashable, Encodable {
        public var name: String
        public var amount: Money
        public var description: String?

        public init(name: String, amount: Money, description: String? = nil) {
            self.name = name
            self.amount = amount
            self.description = description
        }

        enum CodingKeys: String, CodingKey { case name, amount, currency, description }
        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(name, forKey: .name)
            try c.encode(amount.amount, forKey: .amount)
            try c.encode(amount.currency, forKey: .currency)
            try c.encodeIfPresent(description, forKey: .description)
        }
    }

    /// Fields to change. Only non-nil fields are sent.
    public struct Update: Sendable, Hashable, Encodable {
        public var name: String?
        public var description: String?
        public var amount: Money?
        public var active: Bool?

        public init(name: String? = nil, description: String? = nil, amount: Money? = nil, active: Bool? = nil) {
            self.name = name
            self.description = description
            self.amount = amount
            self.active = active
        }

        enum CodingKeys: String, CodingKey { case name, description, amount, currency, active }
        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeIfPresent(name, forKey: .name)
            try c.encodeIfPresent(description, forKey: .description)
            try c.encodeIfPresent(amount?.amount, forKey: .amount)
            try c.encodeIfPresent(amount?.currency, forKey: .currency)
            try c.encodeIfPresent(active, forKey: .active)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, active, name, description, amount, currency, type, unit
        case unitAmount = "unit_amount", taxInclusive = "tax_inclusive", hsnCode = "hsn_code", sacCode = "sac_code"
        case taxRate = "tax_rate", taxID = "tax_id", taxGroupID = "tax_group_id", createdAt = "created_at", updatedAt = "updated_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
        id = try c.decode(ID.self, forKey: .id)
        active = try c.decodeIfPresent(Bool.self, forKey: .active) ?? true
        name = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        amount = try c.decodeMoney(.amount, currency: currency)
        unitAmount = try c.decodeMoneyIfPresent(.unitAmount, currency: currency)
        type = try c.decodeIfPresent(Kind.self, forKey: .type)
        unit = try c.decodeIfPresent(String.self, forKey: .unit)
        taxInclusive = try c.decodeIfPresent(Bool.self, forKey: .taxInclusive)
        hsnCode = try c.decodeIfPresent(String.self, forKey: .hsnCode)
        sacCode = try c.decodeIfPresent(String.self, forKey: .sacCode)
        taxRate = try c.decodeIfPresent(Double.self, forKey: .taxRate)
        taxID = try c.decodeIfPresent(String.self, forKey: .taxID)
        taxGroupID = try c.decodeIfPresent(String.self, forKey: .taxGroupID)
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
}
