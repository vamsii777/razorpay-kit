import Foundation
import RazorpayKit

public protocol RazorpayRefundRoutesProtocol {
    /// Create a refund for a payment
    /// - Parameters:
    ///   - paymentId: The ID of the payment to refund
    ///   - request: The refund request details
    /// - Returns: The created refund
    func create(paymentId: String, request: CreateRefundRequest) async throws -> Refund
    
    /// Fetch a specific refund by ID
    /// - Parameters:
    ///   - paymentId: The ID of the payment
    ///   - refundId: The ID of the refund to fetch
    /// - Returns: The refund details
    func fetch(paymentId: String, refundId: String) async throws -> Refund
}

public struct RazorpayRefundRoutes: RazorpayRefundRoutesProtocol {
    private let client: RazorpayClient
    
    init(client: RazorpayClient) {
        self.client = client
    }
    
    public func create(paymentId: String, request: CreateRefundRequest) async throws -> Refund {
        return try await APIRequestHandler.execute {
            try await client.refund.create(data: request.dictionary, extraHeaders: nil)
        }
    }
    
    public func fetch(paymentId: String, refundId: String) async throws -> Refund {
        return try await APIRequestHandler.execute {
            try await client.refund.fetch(refundID: refundId, queryParams: nil, extraHeaders: nil)
        }
    }
} 
