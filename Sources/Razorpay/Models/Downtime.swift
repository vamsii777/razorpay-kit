import Foundation

/// Represents a payment downtime event in the Razorpay system
public struct Downtime: RazorpayResponse, Codable {
    /// Unique identifier of the downtime's occurrence
    public let id: String?
    
    /// The entity type, always "payment.downtime"
    public let entity: String?
    
    /// The payment method experiencing the downtime
    public let method: DowntimeMethod?
    
    /// Timestamp indicating the start of the downtime
    public let begin: Int?
    
    /// Timestamp indicating the end of the downtime (if known)
    public let end: Int?
    
    /// Current status of the downtime
    public let status: DowntimeStatus?
    
    /// Whether the downtime was scheduled
    public let scheduled: Bool?
    
    /// Severity level of the downtime
    public let severity: DowntimeSeverity?
    
    /// Payment instrument affected by the downtime
    public let instrument: DowntimeInstrument?

    /// Timestamp when the downtime was created
    public let createdAt: Int?

    /// Timestamp when the downtime was last updated
    public let updatedAt: Int?

    private enum CodingKeys: String, CodingKey {
        case id, entity, method, begin, end, status, scheduled, severity, instrument
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Payment methods that can experience downtime
public enum DowntimeMethod: Codable {
    /// Card payments
    case card
    /// Net banking payments
    case netbanking
    /// UPI payments
    case upi
    /// FPX payments (Financial Process Exchange)
    case fpx
    /// Wallet payments
    case wallet
    /// EMI payments
    case emi
    /// NEFT payments
    case neft
    /// RTGS payments
    case rtgs
    /// IMPS payments
    case imps
    /// Unknown payment method (future-proofing)
    case unknown(String)
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        
        switch value.lowercased() {
        case "card": self = .card
        case "netbanking": self = .netbanking
        case "upi": self = .upi
        case "fpx": self = .fpx
        case "wallet": self = .wallet
        case "emi": self = .emi
        case "neft": self = .neft
        case "rtgs": self = .rtgs
        case "imps": self = .imps
        default: self = .unknown(value)
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .card: try container.encode("card")
        case .netbanking: try container.encode("netbanking")
        case .upi: try container.encode("upi")
        case .fpx: try container.encode("fpx")
        case .wallet: try container.encode("wallet")
        case .emi: try container.encode("emi")
        case .neft: try container.encode("neft")
        case .rtgs: try container.encode("rtgs")
        case .imps: try container.encode("imps")
        case .unknown(let value): try container.encode(value)
        }
    }
}

/// Status of a downtime event
public enum DowntimeStatus: String, Codable {
    case scheduled
    case started
    case resolved
    case updated
}

/// Severity level of a downtime event
public enum DowntimeSeverity: String, Codable {
    case high
    case medium
    case low
}

/// Represents the payment instrument affected by the downtime
/// All instrument parameters from the API are stored and accessible dynamically
@dynamicMemberLookup
public struct DowntimeInstrument: Codable {
    /// Internal storage for all instrument parameters
    private let parameters: [String: String]

    /// Bank code for netbanking downtimes (e.g., HDFC, ICIC, SBIN, KKBK, UTIB, PUNB)
    public var bank: String? { parameters["bank"] }

    /// Card network (e.g., AMEX, DICL, MC, RUPAY, VISA, ALL)
    public var network: String? { parameters["network"] }

    /// 4-character issuer code unique to each issuing bank in India (e.g., SBIN, HDFC, ICIC, UTIB, CITI, PUNB, KKBK, CNRB, BKID, BARB, JAKA, UBIN)
    public var issuer: String? { parameters["issuer"] }

    /// Code of the affected Payment Service Provider (e.g., google_pay, phonepe, paytm, bhim)
    public var psp: String? { parameters["psp"] }

    /// Affected VPA handle (e.g., @oksbi). Value is "ALL" when entire UPI system is experiencing downtime
    public var vpaHandle: String? { parameters["vpa_handle"] }

    /// The card type used to process the payment (e.g., credit, debit)
    public var cardType: String? { parameters["card_type"] }

    /// Indicates the UPI payments flow being used (e.g., collect, intent, in_app for Turbo UPI)
    public var flow: String? { parameters["flow"] }

    /// Dynamic member lookup to access any instrument parameter
    /// This allows accessing future parameters as properties automatically
    /// For example: instrument.walletProvider will return parameters["wallet_provider"]
    public subscript(dynamicMember member: String) -> String? {
        // Convert camelCase to snake_case for API compatibility
        let snakeCase = member.camelCaseToSnakeCase()
        return parameters[snakeCase]
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        var params: [String: String] = [:]

        for key in container.allKeys {
            // Try to decode as string
            if let stringValue = try? container.decode(String.self, forKey: key) {
                params[key.stringValue] = stringValue
            }
        }

        parameters = params
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        for (key, value) in parameters {
            let codingKey = DynamicCodingKey(stringValue: key)!
            try container.encode(value, forKey: codingKey)
        }
    }
}

/// Dynamic coding key for handling unknown instrument parameters
private struct DynamicCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

/// Extension to convert camelCase to snake_case
private extension String {
    func camelCaseToSnakeCase() -> String {
        let pattern = "([a-z0-9])([A-Z])"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: self.utf16.count)
        let snakeCase = regex?.stringByReplacingMatches(
            in: self,
            options: [],
            range: range,
            withTemplate: "$1_$2"
        )
        return snakeCase?.lowercased() ?? self.lowercased()
    }
}

/// Collection of downtime events
public struct DowntimeCollection: RazorpayResponse, Codable {
    /// Type of collection
    public let entity: String?
    /// Number of items in the collection
    public let count: Int?
    /// List of downtime events
    public let items: [Downtime]?
} 
