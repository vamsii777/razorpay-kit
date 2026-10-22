import Foundation
import RazorpayCore

/// A Route linked account (`/v2/accounts` with `type: route`) that receives transfers.
/// See https://razorpay.com/docs/api/payments/route/create-linked-account/.
public struct LinkedAccount: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RazorpayID<LinkedAccount>

    public let id: ID
    public let type: String?
    public let status: Status?
    public let email: String?
    public let phone: String?
    public let referenceID: String?
    public let businessType: String?
    public let legalBusinessName: String?
    public let customerFacingBusinessName: String?
    public let contactName: String?
    public let profile: Profile?
    public let legalInfo: LegalInfo?
    public let notes: Notes
    public let live: Bool
    public let holdFunds: Bool
    public let activatedAt: Date?
    public let createdAt: Date?

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let created: Self = "created"
        public static let activated: Self = "activated"
        public static let needsClarification: Self = "needs_clarification"
        public static let underReview: Self = "under_review"
        public static let suspended: Self = "suspended"
    }

    public struct Profile: Sendable, Hashable, Codable {
        public var category: String?
        public var subcategory: String?
        /// Keyed by kind, for example `registered` or `operation`.
        public var addresses: [String: Address]
        public init(category: String? = nil, subcategory: String? = nil, addresses: [String: Address] = [:]) {
            self.category = category; self.subcategory = subcategory; self.addresses = addresses
        }
        public init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            category = try c.decodeIfPresent(String.self, forKey: .category)
            subcategory = try c.decodeIfPresent(String.self, forKey: .subcategory)
            addresses = (try? c.decodeIfPresent([String: Address].self, forKey: .addresses)) ?? [:]
        }
        enum CodingKeys: String, CodingKey { case category, subcategory, addresses }
    }

    public struct LegalInfo: Sendable, Hashable, Codable {
        public var pan: String?
        public var gst: String?
        public var cin: String?
        public init(pan: String? = nil, gst: String? = nil, cin: String? = nil) { self.pan = pan; self.gst = gst; self.cin = cin }
    }

    enum CodingKeys: String, CodingKey {
        case id, type, status, email, phone, profile, notes, live
        case referenceID = "reference_id", businessType = "business_type", legalBusinessName = "legal_business_name"
        case customerFacingBusinessName = "customer_facing_business_name", contactName = "contact_name"
        case legalInfo = "legal_info", holdFunds = "hold_funds", activatedAt = "activated_at", createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        type = try c.decodeIfPresent(String.self, forKey: .type)
        status = try c.decodeIfPresent(Status.self, forKey: .status)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        // `phone` is a number in some responses.
        phone = try (try? c.decodeIfPresent(String.self, forKey: .phone)) ?? c.decodeIfPresent(Int.self, forKey: .phone).map(String.init)
        referenceID = try c.decodeIfPresent(String.self, forKey: .referenceID)
        businessType = try c.decodeIfPresent(String.self, forKey: .businessType)
        legalBusinessName = try c.decodeIfPresent(String.self, forKey: .legalBusinessName)
        customerFacingBusinessName = try c.decodeIfPresent(String.self, forKey: .customerFacingBusinessName)
        contactName = try c.decodeIfPresent(String.self, forKey: .contactName)
        profile = try c.decodeIfPresent(Profile.self, forKey: .profile)
        legalInfo = try c.decodeIfPresent(LegalInfo.self, forKey: .legalInfo)
        notes = try NotesCoding.decode(c, .notes)
        live = try c.decodeFlagIfPresent(.live) ?? false
        holdFunds = try c.decodeFlagIfPresent(.holdFunds) ?? false
        activatedAt = try c.decodeIfPresent(Date.self, forKey: .activatedAt)
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt)
    }

    /// `POST /v2/accounts` for a Route linked account.
    public struct Create: Sendable, Hashable, Encodable {
        public var email: String
        public var phone: String
        public var legalBusinessName: String
        public var businessType: String
        public var contactName: String
        public var referenceID: String?
        public var customerFacingBusinessName: String?
        public var profile: Profile?
        public var legalInfo: LegalInfo?
        public var notes: Notes

        public init(email: String, phone: String, legalBusinessName: String, businessType: String, contactName: String,
                    referenceID: String? = nil, customerFacingBusinessName: String? = nil, profile: Profile? = nil,
                    legalInfo: LegalInfo? = nil, notes: Notes = [:]) {
            self.email = email; self.phone = phone; self.legalBusinessName = legalBusinessName
            self.businessType = businessType; self.contactName = contactName; self.referenceID = referenceID
            self.customerFacingBusinessName = customerFacingBusinessName; self.profile = profile
            self.legalInfo = legalInfo; self.notes = notes
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode("route", forKey: .type)
            try c.encode(email, forKey: .email)
            try c.encode(phone, forKey: .phone)
            try c.encode(legalBusinessName, forKey: .legalBusinessName)
            try c.encode(businessType, forKey: .businessType)
            try c.encode(contactName, forKey: .contactName)
            try c.encodeIfPresent(referenceID, forKey: .referenceID)
            try c.encodeIfPresent(customerFacingBusinessName, forKey: .customerFacingBusinessName)
            try c.encodeIfPresent(profile, forKey: .profile)
            try c.encodeIfPresent(legalInfo, forKey: .legalInfo)
            try c.encodeNotes(notes, .notes)
        }
    }

    /// `PATCH /v2/accounts/:id`. Only set fields change.
    public struct Update: Sendable, Hashable, Encodable {
        public var phone: String?
        public var legalBusinessName: String?
        public var customerFacingBusinessName: String?
        public var contactName: String?
        public var profile: Profile?
        public var legalInfo: LegalInfo?
        public var notes: Notes?
        public init(phone: String? = nil, legalBusinessName: String? = nil, customerFacingBusinessName: String? = nil,
                    contactName: String? = nil, profile: Profile? = nil, legalInfo: LegalInfo? = nil, notes: Notes? = nil) {
            self.phone = phone; self.legalBusinessName = legalBusinessName
            self.customerFacingBusinessName = customerFacingBusinessName; self.contactName = contactName
            self.profile = profile; self.legalInfo = legalInfo; self.notes = notes
        }
        enum CodingKeys: String, CodingKey {
            case phone, profile, notes
            case legalBusinessName = "legal_business_name", customerFacingBusinessName = "customer_facing_business_name"
            case contactName = "contact_name", legalInfo = "legal_info"
        }
    }
}

/// A postal address as Route and Stakeholders send it.
public struct Address: Sendable, Hashable, Codable {
    public var street1: String?
    public var street2: String?
    public var street: String?
    public var city: String?
    public var state: String?
    public var postalCode: String?
    public var country: String?

    public init(street1: String? = nil, street2: String? = nil, street: String? = nil, city: String? = nil,
                state: String? = nil, postalCode: String? = nil, country: String? = nil) {
        self.street1 = street1; self.street2 = street2; self.street = street; self.city = city
        self.state = state; self.postalCode = postalCode; self.country = country
    }

    enum CodingKeys: String, CodingKey { case street1, street2, street, city, state, country, postalCode = "postal_code" }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        street1 = try c.decodeIfPresent(String.self, forKey: .street1)
        street2 = try c.decodeIfPresent(String.self, forKey: .street2)
        street = try c.decodeIfPresent(String.self, forKey: .street)
        city = try c.decodeIfPresent(String.self, forKey: .city)
        state = try c.decodeIfPresent(String.self, forKey: .state)
        // Postal codes arrive as strings or numbers.
        postalCode = try (try? c.decodeIfPresent(String.self, forKey: .postalCode)) ?? c.decodeIfPresent(Int.self, forKey: .postalCode).map(String.init)
        country = try c.decodeIfPresent(String.self, forKey: .country)
    }
}

/// A director, owner or signatory of a linked account. See https://razorpay.com/docs/api/payments/route/stakeholders/.
public struct Stakeholder: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RazorpayID<Stakeholder>

    public let id: ID
    public let name: String?
    public let email: String?
    public let phone: Phone?
    public let relationship: Relationship?
    public let percentageOwnership: Double?
    public let addresses: [String: Address]
    public let kyc: KYC?
    public let notes: Notes

    public struct Phone: Sendable, Hashable, Codable {
        public var primary: String?
        public var secondary: String?
        public init(primary: String? = nil, secondary: String? = nil) { self.primary = primary; self.secondary = secondary }
        public init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            func s(_ k: CodingKeys) throws -> String? {
                try (try? c.decodeIfPresent(String.self, forKey: k)) ?? c.decodeIfPresent(Int.self, forKey: k).map(String.init)
            }
            primary = try s(.primary); secondary = try s(.secondary)
        }
        enum CodingKeys: String, CodingKey { case primary, secondary }
    }

    public struct Relationship: Sendable, Hashable, Codable {
        public var director: Bool
        public var executive: Bool
        public init(director: Bool = false, executive: Bool = false) { self.director = director; self.executive = executive }
        public init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            director = try c.decodeFlagIfPresent(.director) ?? false
            executive = try c.decodeFlagIfPresent(.executive) ?? false
        }
        enum CodingKeys: String, CodingKey { case director, executive }
    }

    public struct KYC: Sendable, Hashable, Codable {
        public var pan: String?
        public init(pan: String? = nil) { self.pan = pan }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, relationship, addresses, kyc, notes
        case percentageOwnership = "percentage_ownership"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        phone = try c.decodeIfPresent(Phone.self, forKey: .phone)
        relationship = try c.decodeIfPresent(Relationship.self, forKey: .relationship)
        percentageOwnership = try c.decodeIfPresent(Double.self, forKey: .percentageOwnership)
        addresses = (try? c.decodeIfPresent([String: Address].self, forKey: .addresses)) ?? [:]
        kyc = try c.decodeIfPresent(KYC.self, forKey: .kyc)
        notes = try NotesCoding.decode(c, .notes)
    }

    /// `POST`/`PATCH /v2/accounts/:id/stakeholders`. Only set fields are sent.
    public struct Details: Sendable, Hashable, Encodable {
        public var name: String?
        public var email: String?
        public var phone: Phone?
        public var relationship: Relationship?
        public var percentageOwnership: Double?
        public var addresses: [String: Address]?
        public var kyc: KYC?
        public var notes: Notes?

        public init(name: String? = nil, email: String? = nil, phone: Phone? = nil, relationship: Relationship? = nil,
                    percentageOwnership: Double? = nil, addresses: [String: Address]? = nil, kyc: KYC? = nil, notes: Notes? = nil) {
            self.name = name; self.email = email; self.phone = phone; self.relationship = relationship
            self.percentageOwnership = percentageOwnership; self.addresses = addresses; self.kyc = kyc; self.notes = notes
        }

        enum CodingKeys: String, CodingKey {
            case name, email, phone, relationship, addresses, kyc, notes, percentageOwnership = "percentage_ownership"
        }

        func validate() -> Result<Self, RazorpayError> {
            if let p = percentageOwnership, !(0...100).contains(p) {
                return .failure(.invalidRequest("percentageOwnership must be between 0 and 100"))
            }
            return .success(self)
        }
    }
}
