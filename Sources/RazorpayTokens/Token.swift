import Foundation
import RazorpayCore
import RazorpayPayments

/// A saved payment method (card, UPI or eMandate) for a customer. See https://razorpay.com/docs/api/payments/tokens/.
public struct Token: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RazorpayID<Token>

    public let id: ID
    /// The token value to pass as `token` in recurring payments.
    public let token: String?
    public let method: Payment.Method?
    public let bank: String?
    public let wallet: String?
    public let card: CardInfo?
    public let vpa: VPA?
    public let recurring: Bool
    public let recurringDetails: RecurringDetails?
    public let authType: String?
    public let mrn: String?
    /// Maximum debit per charge, in minor units, for eMandate/UPI AutoPay tokens.
    public let maxAmount: Int?
    public let status: Status?
    public let compliantWithTokenisationGuidelines: Bool?
    public let dccEnabled: Bool
    public let notes: Notes
    public let usedAt: Date?
    public let createdAt: Date
    public let expiredAt: Date?

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let initiated: Self = "initiated"
        public static let active: Self = "active"
        public static let suspended: Self = "suspended"
        public static let deactivated: Self = "deactivated"
        public static let failed: Self = "failed"
    }

    /// The card behind a card token. Tokens never carry a card ID, so this isn't a ``Card``.
    public struct CardInfo: Sendable, Hashable, Codable {
        public let name: String?
        public let last4: String?
        public let network: Card.Network?
        public let type: Card.Kind?
        public let issuer: String?
        public let international: Bool?
        public let emi: Bool?
        public let subType: String?
        public let expiryMonth: Int?
        public let expiryYear: Int?
        /// Supported flows, for example `["otp": true, "recurring": true]`.
        public let flows: [String: Bool]

        enum CodingKeys: String, CodingKey {
            case name, last4, network, type, issuer, international, emi, flows
            case subType = "sub_type", expiryMonth = "expiry_month", expiryYear = "expiry_year"
        }

        public init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            name = try c.decodeIfPresent(String.self, forKey: .name)
            last4 = try c.decodeIfPresent(String.self, forKey: .last4)
            network = try c.decodeIfPresent(Card.Network.self, forKey: .network)
            type = try c.decodeIfPresent(Card.Kind.self, forKey: .type)
            issuer = try c.decodeIfPresent(String.self, forKey: .issuer)
            international = try c.decodeFlagIfPresent(.international)
            emi = try c.decodeFlagIfPresent(.emi)
            subType = try c.decodeIfPresent(String.self, forKey: .subType)
            // Razorpay sends expiry as a number or a string.
            expiryMonth = try Self.int(c, .expiryMonth)
            expiryYear = try Self.int(c, .expiryYear)
            flows = (try? c.decodeIfPresent([String: Bool].self, forKey: .flows)) ?? [:]
        }

        static func int(_ c: KeyedDecodingContainer<CodingKeys>, _ k: CodingKeys) throws -> Int? {
            if let i = try? c.decodeIfPresent(Int.self, forKey: k) { return i }
            return try c.decodeIfPresent(String.self, forKey: k).flatMap { Int($0) }
        }
    }

    public struct VPA: Sendable, Hashable, Codable {
        public let username: String?
        public let handle: String?
        public let name: String?
    }

    public struct RecurringDetails: Sendable, Hashable, Codable {
        public let status: Status?
        public let failureReason: String?

        public struct Status: RazorpayStringEnum {
            public let rawValue: String
            public init(rawValue: String) { self.rawValue = rawValue }
            public static let initiated: Self = "initiated"
            public static let confirmed: Self = "confirmed"
            public static let rejected: Self = "rejected"
            public static let cancelled: Self = "cancelled"
            public static let paused: Self = "paused"
        }

        enum CodingKeys: String, CodingKey { case status, failureReason = "failure_reason" }
    }

    enum CodingKeys: String, CodingKey {
        case id, token, method, bank, wallet, card, vpa, recurring, mrn, status, notes
        case recurringDetails = "recurring_details", authType = "auth_type", maxAmount = "max_amount"
        case compliantWithTokenisationGuidelines = "compliant_with_tokenisation_guidelines"
        case dccEnabled = "dcc_enabled", usedAt = "used_at", createdAt = "created_at", expiredAt = "expired_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        token = try c.decodeIfPresent(String.self, forKey: .token)
        method = try c.decodeIfPresent(Payment.Method.self, forKey: .method)
        bank = try c.decodeIfPresent(String.self, forKey: .bank)
        wallet = try c.decodeIfPresent(String.self, forKey: .wallet)
        card = try c.decodeIfPresent(CardInfo.self, forKey: .card)
        vpa = try c.decodeIfPresent(VPA.self, forKey: .vpa)
        recurring = try c.decodeFlagIfPresent(.recurring) ?? false
        recurringDetails = try c.decodeIfPresent(RecurringDetails.self, forKey: .recurringDetails)
        authType = try c.decodeIfPresent(String.self, forKey: .authType)
        mrn = try c.decodeIfPresent(String.self, forKey: .mrn)
        maxAmount = try c.decodeIfPresent(Int.self, forKey: .maxAmount)
        status = try c.decodeIfPresent(Status.self, forKey: .status)
        compliantWithTokenisationGuidelines = try c.decodeFlagIfPresent(.compliantWithTokenisationGuidelines)
        dccEnabled = try c.decodeFlagIfPresent(.dccEnabled) ?? false
        notes = try NotesCoding.decode(c, .notes)
        usedAt = try c.decodeIfPresent(Date.self, forKey: .usedAt)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
        expiredAt = try c.decodeIfPresent(Date.self, forKey: .expiredAt)
    }
}

extension Token: WebhookEntity { public static var payloadKey: String { "token" } }

extension RazorpayWebhook.Name {
    public static let tokenConfirmed: Self = "token.confirmed"
    public static let tokenRejected: Self = "token.rejected"
    public static let tokenPaused: Self = "token.paused"
    public static let tokenCancelled: Self = "token.cancelled"
}

/// `{"deleted": true}`.
public struct DeletionResult: Sendable, Hashable, Codable {
    public let deleted: Bool
    public init(deleted: Bool) { self.deleted = deleted }
}
