import Foundation
import RazorpayCore
import RazorpayItems

/// A one-off charge added to a subscription's next invoice.
/// See https://razorpay.com/docs/api/payments/subscriptions/#create-an-add-on.
public struct Addon: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = AddonID

    public let id: ID
    public let item: Item
    public let quantity: Int
    public let subscriptionID: SubscriptionID?
    /// Set once the add-on has been billed.
    public let invoiceID: InvoiceID?
    public let createdAt: Date

    /// The body for `addons.create(for:_:options:)`.
    public struct Create: Sendable, Hashable, Encodable {
        public var item: Item.Create
        public var quantity: Int

        public init(item: Item.Create, quantity: Int = 1) {
            self.item = item
            self.quantity = quantity
        }

        enum CodingKeys: String, CodingKey { case item, quantity }
        public func encode(to encoder: any Encoder) throws {
            guard quantity > 0 else {
                throw EncodingError.invalidValue(quantity, .init(codingPath: [CodingKeys.quantity], debugDescription: "add-on quantity must be positive"))
            }
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(item, forKey: .item)
            try c.encode(quantity, forKey: .quantity)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, item, quantity, subscriptionID = "subscription_id", invoiceID = "invoice_id", createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        item = try c.decode(Item.self, forKey: .item)
        quantity = try c.decodeIfPresent(Int.self, forKey: .quantity) ?? 1
        subscriptionID = try c.decodeIfPresent(SubscriptionID.self, forKey: .subscriptionID)
        invoiceID = try c.decodeIfPresent(InvoiceID.self, forKey: .invoiceID)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}
