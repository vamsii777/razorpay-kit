import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with refunds in the Razorpay API.
public protocol RefundRoutes: RazorpayAPIRoute {
    
    /// Fetches a collection of refunds for the given query parameters.
    func all(queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a refund by its ID.
    func fetch(refundID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a new refund for the given data.
    func create(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Updates a refund by its ID.
    func update(refundID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `RefundRoutes` protocol for Razorpay refund operations.
public struct RazorpayRefundRoutes: RefundRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler

    init(client: RazorpayAPIHandler) {
        self.client = client
    }
    
    public func all(queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.refundURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(refundID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.refundURL)/\(refundID)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func create(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.refundURL)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    @available(*, deprecated, message: "This function is under development and cannot be used.")
    public func update(refundID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.refundURL)/\(refundID)"
        // Note: The original Go code uses PATCH, but it passes queryParams instead of a body. This might be a mistake or specific use case.
        // For a typical PATCH, you would send data in the body, not as query params. Adjust implementation as needed.
        let response = try await client.sendRequest(method: .PATCH, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
