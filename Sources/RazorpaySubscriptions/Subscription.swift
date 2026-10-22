import Foundation
import RazorpayCore

/// A recurring subscription to a ``Plan``. See https://razorpay.com/docs/api/payments/subscriptions/.
public struct Subscription: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = SubscriptionID

    public let id: ID
    public let planID: PlanID
    public let customerID: CustomerID?
    public let status: Status
    public let quantity: Int
    public let totalCount: Int?
    public let paidCount: Int
    public let remainingCount: Int?
    public let authAttempts: Int
    public let customerNotify: Bool
    public let currentStart: Date?
    public let currentEnd: Date?
    public let startAt: Date?
    public let endAt: Date?
    public let endedAt: Date?
    public let chargeAt: Date?
    public let expireBy: Date?
    public let shortURL: String?
    public let hasScheduledChanges: Bool
    public let changeScheduledAt: Date?
    public let source: String?
    public let offerID: OfferID?
    public let paymentMethod: String?
    public let notes: Notes
    public let createdAt: Date

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let created: Self = "created"
        public static let authenticated: Self = "authenticated"
        public static let active: Self = "active"
        public static let pending: Self = "pending"
        public static let halted: Self = "halted"
        public static let cancelled: Self = "cancelled"
        public static let completed: Self = "completed"
        public static let expired: Self = "expired"
        public static let paused: Self = "paused"
    }

    /// When a change, pause or cancellation takes effect.
    public struct Timing: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let now: Self = "now"
        public static let cycleEnd: Self = "cycle_end"
    }

    /// An add-on charged with the first payment of a new subscription.
    public struct UpfrontAddon: Sendable, Hashable, Encodable {
        public var name: String
        public var amount: Money
        public init(name: String, amount: Money) {
            self.name = name
            self.amount = amount
        }
        enum ItemKeys: String, CodingKey { case name, amount, currency }
        enum CodingKeys: String, CodingKey { case item }
        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            var item = c.nestedContainer(keyedBy: ItemKeys.self, forKey: .item)
            try item.encode(name, forKey: .name)
            try item.encode(amount.amount, forKey: .amount)
            try item.encode(amount.currency, forKey: .currency)
        }
    }

    /// The body for ``RazorpayClient/Subscriptions/create(_:options:)``.
    public struct Create: Sendable, Hashable, Encodable {
        public var planID: PlanID
        /// Number of billing cycles.
        public var totalCount: Int
        public var quantity: Int?
        public var startAt: Date?
        public var expireBy: Date?
        public var customerNotify: Bool?
        public var addons: [UpfrontAddon]
        public var offerID: OfferID?
        public var notes: Notes

        public init(planID: PlanID, totalCount: Int, quantity: Int? = nil, startAt: Date? = nil, expireBy: Date? = nil,
                    customerNotify: Bool? = nil, addons: [UpfrontAddon] = [], offerID: OfferID? = nil, notes: Notes = [:]) {
            self.planID = planID
            self.totalCount = totalCount
            self.quantity = quantity
            self.startAt = startAt
            self.expireBy = expireBy
            self.customerNotify = customerNotify
            self.addons = addons
            self.offerID = offerID
            self.notes = notes
        }

        enum CodingKeys: String, CodingKey {
            case quantity, addons, notes
            case planID = "plan_id", totalCount = "total_count", startAt = "start_at", expireBy = "expire_by"
            case customerNotify = "customer_notify", offerID = "offer_id"
        }

        public func encode(to encoder: any Encoder) throws {
            guard totalCount > 0 else {
                throw EncodingError.invalidValue(totalCount, .init(codingPath: [CodingKeys.totalCount], debugDescription: "total_count must be positive"))
            }
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(planID, forKey: .planID)
            try c.encode(totalCount, forKey: .totalCount)
            try c.encodeIfPresent(quantity, forKey: .quantity)
            try c.encodeIfPresent(startAt.map { Int($0.timeIntervalSince1970) }, forKey: .startAt)
            try c.encodeIfPresent(expireBy.map { Int($0.timeIntervalSince1970) }, forKey: .expireBy)
            try c.encodeIfPresent(customerNotify.map { $0 ? 1 : 0 }, forKey: .customerNotify)
            if !addons.isEmpty { try c.encode(addons, forKey: .addons) }
            try c.encodeIfPresent(offerID, forKey: .offerID)
            if !notes.isEmpty { try c.encode(notes, forKey: .notes) }
        }
    }

    /// Changes for ``RazorpayClient/Subscriptions/update(_:_:options:)``. Only non-nil fields are sent.
    public struct Update: Sendable, Hashable, Encodable {
        public var planID: PlanID?
        public var offerID: OfferID?
        public var quantity: Int?
        public var remainingCount: Int?
        public var startAt: Date?
        public var scheduleChangeAt: Timing?
        public var customerNotify: Bool?

        public init(planID: PlanID? = nil, offerID: OfferID? = nil, quantity: Int? = nil, remainingCount: Int? = nil,
                    startAt: Date? = nil, scheduleChangeAt: Timing? = nil, customerNotify: Bool? = nil) {
            self.planID = planID
            self.offerID = offerID
            self.quantity = quantity
            self.remainingCount = remainingCount
            self.startAt = startAt
            self.scheduleChangeAt = scheduleChangeAt
            self.customerNotify = customerNotify
        }

        enum CodingKeys: String, CodingKey {
            case quantity
            case planID = "plan_id", offerID = "offer_id", remainingCount = "remaining_count", startAt = "start_at"
            case scheduleChangeAt = "schedule_change_at", customerNotify = "customer_notify"
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeIfPresent(planID, forKey: .planID)
            try c.encodeIfPresent(offerID, forKey: .offerID)
            try c.encodeIfPresent(quantity, forKey: .quantity)
            try c.encodeIfPresent(remainingCount, forKey: .remainingCount)
            try c.encodeIfPresent(startAt.map { Int($0.timeIntervalSince1970) }, forKey: .startAt)
            try c.encodeIfPresent(scheduleChangeAt, forKey: .scheduleChangeAt)
            try c.encodeIfPresent(customerNotify.map { $0 ? 1 : 0 }, forKey: .customerNotify)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, status, quantity, source, notes
        case planID = "plan_id", customerID = "customer_id", totalCount = "total_count", paidCount = "paid_count"
        case remainingCount = "remaining_count", authAttempts = "auth_attempts", customerNotify = "customer_notify"
        case currentStart = "current_start", currentEnd = "current_end", startAt = "start_at", endAt = "end_at", endedAt = "ended_at"
        case chargeAt = "charge_at", expireBy = "expire_by", shortURL = "short_url", hasScheduledChanges = "has_scheduled_changes"
        case changeScheduledAt = "change_scheduled_at", offerID = "offer_id", paymentMethod = "payment_method", createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        planID = try c.decode(PlanID.self, forKey: .planID)
        customerID = try c.decodeIfPresent(CustomerID.self, forKey: .customerID)
        status = try c.decode(Status.self, forKey: .status)
        quantity = try c.decodeIfPresent(Int.self, forKey: .quantity) ?? 1
        totalCount = try c.decodeIfPresent(Int.self, forKey: .totalCount)
        paidCount = try c.decodeIfPresent(Int.self, forKey: .paidCount) ?? 0
        // Razorpay has sent remaining_count as both a number and a string.
        if let n = try? c.decodeIfPresent(Int.self, forKey: .remainingCount) {
            remainingCount = n
        } else {
            remainingCount = try c.decodeIfPresent(String.self, forKey: .remainingCount).flatMap { Int($0) }
        }
        authAttempts = try c.decodeIfPresent(Int.self, forKey: .authAttempts) ?? 0
        customerNotify = try c.decodeIfPresent(Bool.self, forKey: .customerNotify) ?? true
        currentStart = try c.decodeIfPresent(Date.self, forKey: .currentStart)
        currentEnd = try c.decodeIfPresent(Date.self, forKey: .currentEnd)
        startAt = try c.decodeIfPresent(Date.self, forKey: .startAt)
        endAt = try c.decodeIfPresent(Date.self, forKey: .endAt)
        endedAt = try c.decodeIfPresent(Date.self, forKey: .endedAt)
        chargeAt = try c.decodeIfPresent(Date.self, forKey: .chargeAt)
        expireBy = try c.decodeIfPresent(Date.self, forKey: .expireBy)
        shortURL = try c.decodeIfPresent(String.self, forKey: .shortURL)
        hasScheduledChanges = try c.decodeIfPresent(Bool.self, forKey: .hasScheduledChanges) ?? false
        changeScheduledAt = try c.decodeIfPresent(Date.self, forKey: .changeScheduledAt)
        source = try c.decodeIfPresent(String.self, forKey: .source)
        offerID = try c.decodeIfPresent(OfferID.self, forKey: .offerID)
        paymentMethod = try c.decodeIfPresent(String.self, forKey: .paymentMethod)
        notes = try NotesCoding.decode(c, .notes)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}

extension Subscription: WebhookEntity { public static var payloadKey: String { "subscription" } }

extension RazorpayWebhook.Name {
    public static let subscriptionAuthenticated: Self = "subscription.authenticated"
    public static let subscriptionActivated: Self = "subscription.activated"
    public static let subscriptionCharged: Self = "subscription.charged"
    public static let subscriptionCompleted: Self = "subscription.completed"
    public static let subscriptionUpdated: Self = "subscription.updated"
    public static let subscriptionPending: Self = "subscription.pending"
    public static let subscriptionHalted: Self = "subscription.halted"
    public static let subscriptionCancelled: Self = "subscription.cancelled"
    public static let subscriptionPaused: Self = "subscription.paused"
    public static let subscriptionResumed: Self = "subscription.resumed"
}
