import Foundation
import RazorpayCore

/// A sub-merchant account you manage as a Razorpay partner. See https://razorpay.com/docs/api/partners/account-onboarding/.
public struct Account: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = AccountID

    public let id: ID
    public let type: Kind?
    public let status: Status
    public let email: String?
    public let phone: String?
    public let legalBusinessName: String?
    public let customerFacingBusinessName: String?
    public let businessType: String?
    public let referenceID: String?
    public let contactName: String?
    public let live: Bool
    public let holdFunds: Bool
    public let activatedAt: Date?
    /// Category, sub-category, addresses and business model. Shapes vary, so they stay as JSON.
    public let profile: JSONValue?
    /// PAN, GST and CIN.
    public let legalInfo: JSONValue?
    public let apps: JSONValue?
    public let brand: JSONValue?
    public let contactInfo: JSONValue?
    public let notes: Notes
    public let createdAt: Date

    public struct Kind: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let standard: Self = "standard"
        public static let route: Self = "route"
    }

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let created: Self = "created"
        public static let activated: Self = "activated"
        public static let needsClarification: Self = "needs_clarification"
        public static let underReview: Self = "under_review"
        public static let suspended: Self = "suspended"
    }

    /// The body for ``RazorpayClient/Accounts/create(_:options:)``.
    public struct Create: Sendable, Hashable, Encodable {
        public var email: String
        public var phone: String
        public var legalBusinessName: String
        public var businessType: String
        public var customerFacingBusinessName: String?
        public var referenceID: String?
        public var contactName: String?
        /// `category`, `subcategory`, `addresses` and so on, as in the docs.
        public var profile: JSONValue?
        public var legalInfo: JSONValue?
        public var brand: JSONValue?
        public var contactInfo: JSONValue?
        public var apps: JSONValue?
        public var notes: Notes

        public init(email: String, phone: String, legalBusinessName: String, businessType: String,
                    customerFacingBusinessName: String? = nil, referenceID: String? = nil, contactName: String? = nil,
                    profile: JSONValue? = nil, legalInfo: JSONValue? = nil, brand: JSONValue? = nil,
                    contactInfo: JSONValue? = nil, apps: JSONValue? = nil, notes: Notes = [:]) {
            self.email = email
            self.phone = phone
            self.legalBusinessName = legalBusinessName
            self.businessType = businessType
            self.customerFacingBusinessName = customerFacingBusinessName
            self.referenceID = referenceID
            self.contactName = contactName
            self.profile = profile
            self.legalInfo = legalInfo
            self.brand = brand
            self.contactInfo = contactInfo
            self.apps = apps
            self.notes = notes
        }

        enum CodingKeys: String, CodingKey {
            case email, phone, profile, brand, apps, notes
            case legalBusinessName = "legal_business_name", businessType = "business_type"
            case customerFacingBusinessName = "customer_facing_business_name", referenceID = "reference_id"
            case contactName = "contact_name", legalInfo = "legal_info", contactInfo = "contact_info"
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(email, forKey: .email)
            try c.encode(phone, forKey: .phone)
            try c.encode(legalBusinessName, forKey: .legalBusinessName)
            try c.encode(businessType, forKey: .businessType)
            try c.encodeIfPresent(customerFacingBusinessName, forKey: .customerFacingBusinessName)
            try c.encodeIfPresent(referenceID, forKey: .referenceID)
            try c.encodeIfPresent(contactName, forKey: .contactName)
            try c.encodeIfPresent(profile, forKey: .profile)
            try c.encodeIfPresent(legalInfo, forKey: .legalInfo)
            try c.encodeIfPresent(brand, forKey: .brand)
            try c.encodeIfPresent(contactInfo, forKey: .contactInfo)
            try c.encodeIfPresent(apps, forKey: .apps)
            if !notes.isEmpty { try c.encode(notes, forKey: .notes) }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, type, status, email, phone, live, profile, apps, brand, notes
        case legalBusinessName = "legal_business_name", customerFacingBusinessName = "customer_facing_business_name"
        case businessType = "business_type", referenceID = "reference_id", contactName = "contact_name"
        case holdFunds = "hold_funds", activatedAt = "activated_at", legalInfo = "legal_info", contactInfo = "contact_info"
        case createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        type = try c.decodeIfPresent(Kind.self, forKey: .type)
        status = try c.decode(Status.self, forKey: .status)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        phone = try c.decodeIfPresent(String.self, forKey: .phone)
        legalBusinessName = try c.decodeIfPresent(String.self, forKey: .legalBusinessName)
        customerFacingBusinessName = try c.decodeIfPresent(String.self, forKey: .customerFacingBusinessName)
        businessType = try c.decodeIfPresent(String.self, forKey: .businessType)
        referenceID = try c.decodeIfPresent(String.self, forKey: .referenceID)
        contactName = try c.decodeIfPresent(String.self, forKey: .contactName)
        live = try c.decodeIfPresent(Bool.self, forKey: .live) ?? false
        holdFunds = try c.decodeIfPresent(Bool.self, forKey: .holdFunds) ?? false
        activatedAt = try c.decodeIfPresent(Date.self, forKey: .activatedAt)
        profile = try c.decodeIfPresent(JSONValue.self, forKey: .profile)
        legalInfo = try c.decodeIfPresent(JSONValue.self, forKey: .legalInfo)
        apps = try c.decodeIfPresent(JSONValue.self, forKey: .apps)
        brand = try c.decodeIfPresent(JSONValue.self, forKey: .brand)
        contactInfo = try c.decodeIfPresent(JSONValue.self, forKey: .contactInfo)
        notes = try NotesCoding.decode(c, .notes)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}

extension Account: WebhookEntity { public static var payloadKey: String { "account" } }

extension RazorpayWebhook.Name {
    public static let accountActivated: Self = "account.activated"
    public static let accountUnderReview: Self = "account.under_review"
    public static let accountNeedsClarification: Self = "account.needs_clarification"
    public static let accountSuspended: Self = "account.suspended"
    public static let accountRejected: Self = "account.rejected"
}
