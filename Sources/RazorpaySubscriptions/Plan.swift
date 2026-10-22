import Foundation
import RazorpayCore
import RazorpayItems

/// A billing plan: an item charged every `interval` `period`s.
/// See https://razorpay.com/docs/api/payments/subscriptions/#create-a-plan.
public struct Plan: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = PlanID

    public let id: ID
    public let period: Period
    public let interval: Int
    public let item: Item
    public let notes: Notes
    public let createdAt: Date

    /// The billing frequency unit.
    public struct Period: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let daily: Self = "daily"
        public static let weekly: Self = "weekly"
        public static let monthly: Self = "monthly"
        public static let quarterly: Self = "quarterly"
        public static let yearly: Self = "yearly"
    }

    /// The body for ``RazorpayClient/Plans/create(_:options:)``.
    public struct Create: Sendable, Hashable, Encodable {
        public var period: Period
        /// Charge every `interval` periods. Daily plans need an interval of at least 7.
        public var interval: Int
        public var item: Item.Create
        public var notes: Notes

        public init(period: Period, interval: Int = 1, item: Item.Create, notes: Notes = [:]) {
            self.period = period
            self.interval = interval
            self.item = item
            self.notes = notes
        }

        enum CodingKeys: String, CodingKey { case period, interval, item, notes }
        public func encode(to encoder: any Encoder) throws {
            guard interval > 0 else {
                throw EncodingError.invalidValue(interval, .init(codingPath: [CodingKeys.interval], debugDescription: "plan interval must be positive"))
            }
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(period, forKey: .period)
            try c.encode(interval, forKey: .interval)
            try c.encode(item, forKey: .item)
            if !notes.isEmpty { try c.encode(notes, forKey: .notes) }
        }
    }

    enum CodingKeys: String, CodingKey { case id, period, interval, item, notes, createdAt = "created_at" }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        period = try c.decode(Period.self, forKey: .period)
        interval = try c.decodeIfPresent(Int.self, forKey: .interval) ?? 1
        item = try c.decode(Item.self, forKey: .item)
        notes = try NotesCoding.decode(c, .notes)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}
