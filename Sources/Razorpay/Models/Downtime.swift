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
    
    /// Optional UPI flow type for UPI-related downtimes
    public let flow: String?
    
    private enum CodingKeys: String, CodingKey {
        case id, entity, method, begin, end, status, scheduled, severity, instrument
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case flow
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
public struct DowntimeInstrument: Codable {
    /// Bank code for netbanking downtimes
    public let bank: String?
    /// UPI handle for UPI downtimes
    public let vpa: String?
    /// PSP name for UPI downtimes
    public let psp: String?
    /// Card issuer for card downtimes
    public let issuer: String?
    /// Card network for card downtimes
    public let network: String?
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
