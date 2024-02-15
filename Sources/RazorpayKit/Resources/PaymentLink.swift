import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with payment links in the Razorpay API.
public protocol PaymentLinkRoutes: RazorpayAPIRoute {
    
    /// Fetches multiple payment links for the given query parameters.
    func all(queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a payment link by its ID.
    func fetch(paymentLinkID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a new payment link for the given data.
    func create(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Cancels a payment link.
    func cancel(paymentLinkID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Sends or resends a notification for a payment link via the specified medium.
    func notifyBy(paymentLinkID: String, medium: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Updates a payment link with the given data.
    func update(paymentLinkID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `PaymentLinkRoutes` protocol for Razorpay payment link operations.
public struct RazorpayPaymentLinkRoutes: PaymentLinkRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler
    private let baseUrl: String

    init(client: RazorpayAPIHandler, baseUrl: String) {
        self.client = client
        self.baseUrl = baseUrl
    }
    
    public func all(queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentLinkURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(paymentLinkID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentLinkURL)/\(paymentLinkID)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func create(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentLinkURL)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func cancel(paymentLinkID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentLinkURL)/\(paymentLinkID)/cancel"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func notifyBy(paymentLinkID: String, medium: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentLinkURL)/\(paymentLinkID)/notify_by/\(medium)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func update(paymentLinkID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentLinkURL)/\(paymentLinkID)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .PATCH, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
