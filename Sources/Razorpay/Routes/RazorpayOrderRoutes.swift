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
    ///
    /// Creates a new order in Razorpay that can be used to accept payments from customers.
    ///
    /// ```swift
    /// let order = try await razorpay.orders.create(
    ///     amount: 10000, // ₹100.00
    ///     currency: "INR",
    ///     receipt: "order_123",
    ///     notes: ["customer_name": "John Doe"]
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - amount: Payment amount in smallest currency sub-unit (e.g., paise for INR)
    ///   - currency: ISO currency code (e.g., "INR")
    ///   - receipt: Optional unique receipt number for your reference
    ///   - notes: Optional key-value pairs for additional information
    ///   - partialPayment: Optional flag to allow partial payments
    ///   - firstPaymentMinAmount: Optional minimum amount for first partial payment
    /// - Returns: The created order
    /// - Throws: ``RazorpayError`` if the request fails or response is invalid
    func create(
        amount: Int,
        currency: String,
        receipt: String?,
        notes: [String: String]?,
        partialPayment: Bool?,
        firstPaymentMinAmount: Int?
    ) async throws -> RazorpayOrder
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
    
    public func create(
        amount: Int,
        currency: String,
        receipt: String? = nil,
        notes: [String: String]? = nil,
        partialPayment: Bool? = nil,
        firstPaymentMinAmount: Int? = nil
    ) async throws -> RazorpayOrder {
        
        try APIRequestHandler.validateMinimum(
            amount,
            minimum: 100,
            field: "amount",
            message: "The amount must be at least 100 (₹1.00 for INR)"
        )
        
        // Build request data
        var data: [String: Any] = [
            "amount": amount,
            "currency": currency
        ]
        
        // Add optional parameters if provided
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
        
        // Execute request with common error handling
        return try await APIRequestHandler.execute {
            try await client.order.create(data: data)
        }
    }
}
