import RazorpayKit
import Foundation
import NIOHTTP1

/// Protocol defining routes for interacting with Razorpay orders
///
/// Use this protocol to create and manage orders through the Razorpay API.
/// Orders represent payment requests that can be fulfilled by customers.
///
/// ## Overview
/// The protocol provides methods to:
/// - Create new orders with specified amount and currency
/// - Support partial payments with minimum amount constraints
/// - Attach custom metadata through notes
///
/// ## Topics
/// ### Creating Orders
/// - ``create(amount:currency:receipt:notes:partialPayment:firstPaymentMinAmount:)``
public protocol RazorpayOrderRoutes: Sendable {
    /// Creates a new order with the specified parameters
    /// - Parameter request: The order creation request
    /// - Returns: The created order
    /// - Throws: ``RazorpayError`` if the request fails or response is invalid
    func create(_ request: OrderRequest) async throws -> OrderResponse
    
    /// Convenience method to create an order with basic parameters
    /// - Parameters:
    ///   - amount: Payment amount in smallest currency sub-unit (e.g., paise for INR)
    ///   - currency: ISO currency code (e.g., "INR")
    ///   - receipt: Optional unique receipt number for your reference
    ///   - notes: Optional key-value pairs for additional information
    /// - Returns: The created order
    /// - Throws: ``RazorpayError`` if the request fails or response is invalid
    func create(
        amount: Int,
        currency: String,
        receipt: String?,
        notes: [String: String]?
    ) async throws -> OrderResponse
}

/// Implementation of RazorpayOrderRoutes using RazorpayKit
///
/// This struct provides the concrete implementation of ``RazorpayOrderRoutes``
/// using the RazorpayKit client library.
///
/// ## Topics
/// ### Creating an Instance
/// - ``init(client:)``
public struct RazorpayKitOrderRoutes: RazorpayOrderRoutes {
    private let client: RazorpayClient
    
    /// Creates a new instance with the specified client
    /// - Parameter client: The RazorpayKit client to use for API requests
    public init(client: RazorpayClient) {
        self.client = client
    }
    
    public func create(_ request: OrderRequest) async throws -> OrderResponse {
        try APIRequestHandler.validateMinimum(
            request.amount,
            minimum: 100,
            field: "amount",
            message: "The amount must be at least 100 (₹1.00 for INR)"
        )
        
        return try await APIRequestHandler.execute {
            try await client.order.create(data: request.dictionary)
        }
    }
    
    public func create(
        amount: Int,
        currency: String,
        receipt: String? = nil,
        notes: [String: String]? = nil
    ) async throws -> OrderResponse {
        try await create(OrderRequest(
            amount: amount,
            currency: currency,
            receipt: receipt,
            notes: notes
        ))
    }
}
