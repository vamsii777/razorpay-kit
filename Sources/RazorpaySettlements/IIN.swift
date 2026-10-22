import Foundation
import RazorpayCore

/// Card details for an issuer identification number (the first 6 to 9 digits of a card or token).
/// See https://razorpay.com/docs/api/payments/cards/iin-api/.
public struct IIN: Sendable, Hashable, Decodable {
    public let iin: String
    public let network: String?
    public let type: CardType?
    public let subType: String?
    public let issuerCode: String?
    public let issuerName: String?
    public let international: Bool
    public let isTokenized: Bool
    /// For token IINs, the IIN of the underlying card.
    public let cardIIN: String?
    public let emiAvailable: Bool
    public let recurringAvailable: Bool
    public let authenticationTypes: [String]

    public struct CardType: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let credit: Self = "credit"
        public static let debit: Self = "debit"
        public static let prepaid: Self = "prepaid"
    }

    /// The flow to list IINs for with `iins.list(flow:options:)`.
    public struct Flow: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let otp: Self = "otp"
        public static let rupay: Self = "rupay"
    }

    /// A sub-type to list IINs for with `iins.list(subType:options:)`.
    public struct SubType: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let business: Self = "business"
    }

    struct Available: Decodable { let available: Bool? }
    struct AuthType: Decodable { let type: String }

    enum CodingKeys: String, CodingKey {
        case iin, network, type, international, emi, recurring
        case subType = "sub_type", issuerCode = "issuer_code", issuerName = "issuer_name", isTokenized = "is_tokenized"
        case cardIIN = "card_iin", authenticationTypes = "authentication_types"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        iin = try c.decode(String.self, forKey: .iin)
        network = try c.decodeIfPresent(String.self, forKey: .network)
        type = try c.decodeIfPresent(CardType.self, forKey: .type)
        subType = try c.decodeIfPresent(String.self, forKey: .subType)
        issuerCode = try c.decodeIfPresent(String.self, forKey: .issuerCode)
        issuerName = try c.decodeIfPresent(String.self, forKey: .issuerName)
        international = try c.decodeIfPresent(Bool.self, forKey: .international) ?? false
        isTokenized = try c.decodeIfPresent(Bool.self, forKey: .isTokenized) ?? false
        cardIIN = try c.decodeIfPresent(String.self, forKey: .cardIIN)
        emiAvailable = try c.decodeIfPresent(Available.self, forKey: .emi)?.available ?? false
        recurringAvailable = try c.decodeIfPresent(Available.self, forKey: .recurring)?.available ?? false
        authenticationTypes = try c.decodeIfPresent([AuthType].self, forKey: .authenticationTypes)?.map(\.type) ?? []
    }
}

/// `{"count": n, "iins": ["…"]}` from the IIN list endpoint.
struct IINList: Decodable, Sendable { let iins: [String]? }
