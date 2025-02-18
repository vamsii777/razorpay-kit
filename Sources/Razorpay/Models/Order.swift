import Foundation

/// Represents a request to create a new Razorpay order
public struct OrderRequest: Codable, Sendable {
    /// Payment amount in smallest currency sub-unit (e.g., paise for INR)
    public let amount: Int
    
    /// ISO currency code (e.g., "INR")
    public let currency: String
    
    /// Optional unique receipt number for your reference
    public let receipt: String?
    
    /// Optional key-value pairs for additional information
    public let notes: [String: String]?
    
    /// Optional flag to allow partial payments
    public let partialPayment: Bool?
    
    /// Optional minimum amount for first partial payment
    public let firstPaymentMinAmount: Int?
    
    /// Creates a new order request
    /// - Parameters:
    ///   - amount: Payment amount in smallest currency sub-unit (e.g., paise for INR)
    ///   - currency: ISO currency code (e.g., "INR")
    ///   - receipt: Optional unique receipt number for your reference
    ///   - notes: Optional key-value pairs for additional information
    ///   - partialPayment: Optional flag to allow partial payments
    ///   - firstPaymentMinAmount: Optional minimum amount for first partial payment
    public init(
        amount: Int,
        currency: String,
        receipt: String? = nil,
        notes: [String: String]? = nil,
        partialPayment: Bool? = nil,
        firstPaymentMinAmount: Int? = nil
    ) {
        self.amount = amount
        self.currency = currency
        self.receipt = receipt
        self.notes = notes
        self.partialPayment = partialPayment
        self.firstPaymentMinAmount = firstPaymentMinAmount
    }
    
    /// Converts the request to a dictionary format for API submission
    internal var dictionary: [String: Any] {
        var data: [String: Any] = [
            "amount": amount,
            "currency": currency
        ]
        
        if let receipt = receipt {
            data["receipt"] = receipt
        }
        if let notes = notes {
            data["notes"] = notes
        }
        if let partialPayment = partialPayment {
            data["partial_payment"] = partialPayment
        }
        if let firstPaymentMinAmount = firstPaymentMinAmount {
            data["first_payment_min_amount"] = firstPaymentMinAmount
        }
        
        return data
    }
}

public struct OrderResponse: RazorpayResponse, Sendable {
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
    
    public enum Status: String, Sendable, Codable {
        /// Order is created but no payment attempted
        case created
        /// Payment has been attempted on this order
        case attempted
        /// Payment has been successfully captured
        case paid
    }
    
    // Add CodingKeys to handle snake_case to camelCase conversion
    private enum CodingKeys: String, CodingKey {
        case id
        case amount
        case amountPaid = "amount_paid"
        case amountDue = "amount_due"
        case currency
        case receipt
        case status
        case attempts
        case notes
        case createdAt = "created_at"
    }

    public init(id: String, amount: Int, amountPaid: Int, amountDue: Int, currency: String, receipt: String?, status: Status, attempts: Int, notes: [String: String], createdAt: Date) {
        self.id = id
        self.amount = amount
        self.amountPaid = amountPaid
        self.amountDue = amountDue
        self.currency = currency
        self.receipt = receipt
        self.status = status
        self.attempts = attempts
        self.notes = notes
        self.createdAt = createdAt
    }

    public init(response: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        // Handle empty notes array by converting to empty dictionary
        if let notesArray = response["notes"] as? [Any], notesArray.isEmpty {
            var mutableResponse = response
            mutableResponse["notes"] = [String: String]()
            let updatedData = try JSONSerialization.data(withJSONObject: mutableResponse)
            self = try decoder.decode(OrderResponse.self, from: updatedData)
            return
        }
        
        self = try decoder.decode(OrderResponse.self, from: data)
    }
} 