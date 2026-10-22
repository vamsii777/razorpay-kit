import Foundation
import RazorpayCore

/// A product (such as `payment_gateway` or `payment_links`) requested for a partner's sub-merchant account,
/// with its configuration and outstanding KYC requirements.
/// See https://razorpay.com/docs/api/partners/product-configuration/.
public struct AccountProduct: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = AccountProductID

    public let id: ID
    public let accountID: AccountID
    public let productName: ProductName
    public let activationStatus: ActivationStatus
    /// The configuration you asked for. Its shape varies by product, so it stays as JSON.
    public let requestedConfiguration: JSONValue?
    /// The configuration in effect.
    public let activeConfiguration: JSONValue?
    public let requirements: [Requirement]
    public let tnc: AcceptedTerms?
    public let requestedAt: Date?

    public struct ProductName: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let paymentGateway: Self = "payment_gateway"
        public static let paymentLinks: Self = "payment_links"
        public static let route: Self = "route"
    }

    public struct ActivationStatus: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let requested: Self = "requested"
        public static let needsClarification: Self = "needs_clarification"
        public static let underReview: Self = "under_review"
        public static let activated: Self = "activated"
        public static let suspended: Self = "suspended"
    }

    /// Something Razorpay still needs before activating the product.
    public struct Requirement: Sendable, Hashable, Decodable {
        public let fieldReference: String
        public let resolutionURL: String?
        public let status: String?
        public let reasonCode: String?

        enum CodingKeys: String, CodingKey {
            case status, fieldReference = "field_reference", resolutionURL = "resolution_url", reasonCode = "reason_code"
        }
    }

    /// The terms the sub-merchant accepted.
    public struct AcceptedTerms: Sendable, Hashable, Decodable {
        public let id: String?
        public let accepted: Bool
        public let acceptedAt: Date?
        enum CodingKeys: String, CodingKey { case id, accepted, acceptedAt = "accepted_at" }
    }

    /// The body for ``RazorpayClient/AccountProducts/request(_:for:options:)``.
    public struct Request: Sendable, Hashable, Encodable {
        public var productName: ProductName
        public var tncAccepted: Bool?
        /// The IP address the sub-merchant accepted the terms from. Required when `tncAccepted` is `true`.
        public var ip: String?

        public init(productName: ProductName, tncAccepted: Bool? = nil, ip: String? = nil) {
            self.productName = productName
            self.tncAccepted = tncAccepted
            self.ip = ip
        }

        enum CodingKeys: String, CodingKey { case productName = "product_name", tncAccepted = "tnc_accepted", ip }
    }

    enum CodingKeys: String, CodingKey {
        case id, requirements, tnc
        case accountID = "account_id", productName = "product_name", activationStatus = "activation_status"
        case requestedConfiguration = "requested_configuration", activeConfiguration = "active_configuration", requestedAt = "requested_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        accountID = try c.decode(AccountID.self, forKey: .accountID)
        productName = try c.decode(ProductName.self, forKey: .productName)
        activationStatus = try c.decode(ActivationStatus.self, forKey: .activationStatus)
        requestedConfiguration = try c.decodeIfPresent(JSONValue.self, forKey: .requestedConfiguration)
        activeConfiguration = try c.decodeIfPresent(JSONValue.self, forKey: .activeConfiguration)
        requirements = try c.decodeIfPresent([Requirement].self, forKey: .requirements) ?? []
        tnc = try c.decodeIfPresent(AcceptedTerms.self, forKey: .tnc)
        requestedAt = try c.decodeIfPresent(Date.self, forKey: .requestedAt)
    }
}

/// The current terms and conditions for a product.
/// See https://razorpay.com/docs/api/partners/terms-conditions/.
public struct ProductTerms: Sendable, Hashable, Decodable {
    public let id: String
    public let productName: AccountProduct.ProductName
    /// Links to each document, keyed by name (`terms`, `privacy`, `agreement`).
    public let documents: [String: String]
    public let lastPublishedAt: Date?

    enum CodingKeys: String, CodingKey { case id, productName = "product_name", documents = "tnc", lastPublishedAt = "last_published_at" }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        productName = try c.decode(AccountProduct.ProductName.self, forKey: .productName)
        documents = try c.decodeIfPresent([String: String].self, forKey: .documents) ?? [:]
        lastPublishedAt = try c.decodeIfPresent(Date.self, forKey: .lastPublishedAt)
    }
}
