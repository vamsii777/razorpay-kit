import Foundation
import RazorpayKit

/// Details that can be expanded in payment responses
public enum PaymentExpansion: String {
    /// Expand card details
    case card
    /// Expand EMI details
    case emi
    /// Expand offers details
    case offers
    /// Expand UPI details
    case upi
}

/// Protocol defining routes for interacting with Razorpay payments
///
/// Use this protocol to fetch and manage payments through the Razorpay API.
/// Payments represent successful or failed transaction attempts by customers.
///
/// ## Overview
/// The protocol provides methods to:
/// - Fetch payment details by ID
/// - Fetch payment details with expanded card or EMI information
/// - Fetch payments for a specific order
/// - Handle payment-specific errors
///
/// ## Topics
/// ### Fetching Payments
/// - ``fetch(id:)``
/// - ``fetch(id:expand:)``
/// - ``fetchForOrder(id:)``
public protocol RazorpayPaymentRoutes: Sendable {
    /// Payment details that can be expanded
    typealias Expandable = Set<PaymentExpansion>
    
    /// Fetches details of a specific payment
    /// - Parameter id: Unique identifier of the payment
    /// - Returns: The payment details
    /// - Throws: ``RazorpayError`` if the request fails or response is invalid
    func fetch(id: String) async throws -> Payment
    
    /// Fetches details of a specific payment with expanded information
    /// - Parameters:
    ///   - id: Unique identifier of the payment
    ///   - expand: Set of details to expand in the response
    /// - Returns: The payment details with requested expansions
    /// - Throws: ``RazorpayError`` if the request fails or response is invalid
    func fetch(id: String, expand: Expandable) async throws -> Payment
    
    /// Fetches all payments for a specific order
    /// - Parameter id: Unique identifier of the order
    /// - Returns: Collection of payments for the order
    /// - Throws: ``RazorpayError`` if the request fails or response is invalid
    func fetchForOrder(id: String) async throws -> PaymentCollection
}

/// Implementation of RazorpayPaymentRoutes using RazorpayKit
public struct RazorpayKitPaymentRoutes: RazorpayPaymentRoutes {
    private let client: RazorpayClient
    
    public init(client: RazorpayClient) {
        self.client = client
    }
    
    public func fetch(id: String) async throws -> Payment {
        try await fetch(id: id, expand: [])
    }
    
    public func fetch(id: String, expand: Expandable) async throws -> Payment {
        let queryParams: [String: String]? = expand.isEmpty ? nil : [
            "expand[]": expand.map(\.rawValue).joined(separator: ",")
        ]
        
        return try await APIRequestHandler.execute {
            try await client.payment.fetch(paymentID: id, queryParams: queryParams, extraHeaders: nil)
        }
    }
    
    public func fetchForOrder(id: String) async throws -> PaymentCollection {
        return try await APIRequestHandler.execute {
            try await client.order.payments(orderID: id, queryParams: nil, extraHeaders: nil)
        }
    }
} 