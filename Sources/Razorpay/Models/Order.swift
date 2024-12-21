import Foundation

public struct RazorpayOrder: Sendable, RazorpayResponse {
    /// The unique identifier of the order
    public let id: String
    
    /// The amount for which the order was created (in currency subunits)
    public let amount: Int
    
    /// The amount that has been paid
    public let amountPaid: Int
    
    /// The amount that is pending to be paid
    public let amountDue: Int
    
    /// The currency of the order
    public let currency: String
    
    /// Receipt number that corresponds to this order
    public let receipt: String?
    
    /// Current status of the order
    public let status: Status
    
    /// Number of payment attempts made
    public let attempts: Int
    
    /// Additional notes attached to the order
    public let notes: [String: String]
    
    /// Unix timestamp of when the order was created
    public let createdAt: Date
    
    public enum Status: String, Sendable {
        /// Order is created but no payment attempted
        case created
        /// Payment has been attempted on this order
        case attempted
        /// Payment has been successfully captured
        case paid
    }
    
    public init(response: [String: Any]) throws {
        guard let id = response["id"] as? String else {
            throw RazorpayError.invalidResponse("Missing or invalid 'id' in order response")
        }
        guard let amount = response["amount"] as? Int else {
            throw RazorpayError.invalidResponse("Missing or invalid 'amount' in order response")
        }
        guard let amountPaid = response["amount_paid"] as? Int else {
            throw RazorpayError.invalidResponse("Missing or invalid 'amount_paid' in order response")
        }
        guard let amountDue = response["amount_due"] as? Int else {
            throw RazorpayError.invalidResponse("Missing or invalid 'amount_due' in order response")
        }
        guard let currency = response["currency"] as? String else {
            throw RazorpayError.invalidResponse("Missing or invalid 'currency' in order response")
        }
        guard let statusString = response["status"] as? String,
              let status = Status(rawValue: statusString) else {
            throw RazorpayError.invalidResponse("Missing or invalid 'status' in order response")
        }
        guard let attempts = response["attempts"] as? Int else {
            throw RazorpayError.invalidResponse("Missing or invalid 'attempts' in order response")
        }
        guard let createdAtTimestamp = response["created_at"] as? Int else {
            throw RazorpayError.invalidResponse("Missing or invalid 'created_at' in order response")
        }
        
        self.id = id
        self.amount = amount
        self.amountPaid = amountPaid
        self.amountDue = amountDue
        self.currency = currency
        self.receipt = response["receipt"] as? String
        self.status = status
        self.attempts = attempts
        self.notes = (response["notes"] as? [String: String]) ?? [:]
        self.createdAt = Date(timeIntervalSince1970: TimeInterval(createdAtTimestamp))
    }
} 