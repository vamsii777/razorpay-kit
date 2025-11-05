import Foundation
import RazorpayKit

/// Protocol defining routes for interacting with Razorpay payment downtimes
///
/// Use this protocol to fetch information about payment downtimes through the Razorpay API.
/// Payment downtimes represent periods when specific payment methods are unavailable.
///
/// ## Overview
/// The protocol provides methods to:
/// - Fetch all payment downtimes
/// - Fetch a specific downtime by ID
///
/// ## Topics
/// ### Fetching Downtimes
/// - ``fetchAll()``
/// - ``fetch(id:)``
public protocol RazorpayDowntimeRoutes: Sendable {
    /// Fetches all payment downtimes
    /// - Returns: Collection of payment downtimes
    /// - Throws: ``RazorpayError`` if the request fails or response is invalid
    func fetchAll() async throws -> DowntimeCollection
    
    /// Fetches details of a specific payment downtime
    /// - Parameter id: Unique identifier of the downtime
    /// - Returns: The downtime details
    /// - Throws: ``RazorpayError`` if the request fails or response is invalid
    func fetch(id: String) async throws -> Downtime
}

/// Implementation of RazorpayDowntimeRoutes using RazorpayKit
public struct RazorpayKitDowntimeRoutes: RazorpayDowntimeRoutes {
    private let client: RazorpayClient
    
    public init(client: RazorpayClient) {
        self.client = client
    }
    
    public func fetchAll() async throws -> DowntimeCollection {
        return try await APIRequestHandler.execute {
            try await client.payment.fetchPaymentDowntime(queryParams: nil, extraHeaders: nil)
        }
    }
    
    public func fetch(id: String) async throws -> Downtime {
        return try await APIRequestHandler.execute {
            try await client.payment.fetchPaymentDowntimeById(downtimeId: id, queryParams: nil, extraHeaders: nil)
        }
    }
}
