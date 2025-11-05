import Foundation

public struct Refund: Codable, Sendable, RazorpayResponse {
    /// The unique identifier of the refund
    public let id: String
    
    /// Indicates the type of entity (always "refund")
    public let entity: String
    
    /// The amount that was refunded (in smallest currency unit)
    public let amount: Int
    
    /// The currency of the refund
    public let currency: String
    
    /// The ID of the payment being refunded
    public let paymentId: String
    
    /// Unix timestamp of when the refund was created
    public let createdAt: Int
    
    /// Optional batch ID if refund was part of a batch
    public let batchId: String?
    
    /// Status of the refund (pending, processed, failed)
    public let status: RefundStatus
    
    /// Speed at which the refund was processed
    public let speedProcessed: RefundSpeed
    
    /// Speed that was requested for the refund
    public let speedRequested: RefundSpeed
    
    /// Optional notes associated with the refund
    public let notes: [String: String]?
    
    /// Optional receipt number for reference
    public let receipt: String?
    
    /// Acquirer data containing reference numbers
    public let acquirerData: AcquirerData?
    
    enum CodingKeys: String, CodingKey {
        case id
        case entity
        case amount
        case currency
        case paymentId = "payment_id"
        case createdAt = "created_at"
        case batchId = "batch_id"
        case status
        case speedProcessed = "speed_processed"
        case speedRequested = "speed_requested"
        case notes
        case receipt
        case acquirerData = "acquirer_data"
    }
}

public enum RefundStatus: String, Codable, Sendable {
    case pending
    case processed
    case failed
}

public enum RefundSpeed: String, Codable, Sendable {
    case normal
    case instant
    case optimum
}

public struct AcquirerData: Codable, Sendable {
    public let arn: String?
    // Add other acquirer data fields as needed
}

// Request models
public struct CreateRefundRequest: Codable, Sendable {
    /// Amount to be refunded (optional - if not provided, full amount is refunded)
    public let amount: Int?
    
    /// Speed of refund processing (optional - defaults to normal)
    public let speed: RefundSpeed?
    
    /// Notes for the refund (optional)
    public let notes: [String: String]?
    
    /// Receipt number for reference (optional)
    public let receipt: String?
    
    enum CodingKeys: String, CodingKey {
        case amount
        case speed
        case notes
        case receipt
    }
    
    public init(amount: Int? = nil, speed: RefundSpeed? = nil, notes: [String: String]? = nil, receipt: String? = nil) {
        self.amount = amount
        self.speed = speed
        self.notes = notes
        self.receipt = receipt
    }

    /// Converts the request to a dictionary format for API submission
    internal var dictionary: [String: Any] {
        var data: [String: Any] = [
            "amount": amount ?? 0,
            "speed": speed?.rawValue ?? "normal"
        ]
        
        if let notes = notes {
            data["notes"] = notes
        }
        if let receipt = receipt {
            data["receipt"] = receipt
        }
        return data
    }
}
