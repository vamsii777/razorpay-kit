import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with webhooks in the Razorpay API.
public protocol WebhookRoutes: RazorpayAPIRoute {
    
    /// Creates a new webhook for the given data.
    func create(accountId: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Retrieves and views the details of a webhook.
    func fetch(webhookId: String, accountId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Updates the details of a webhook.
    func edit(webhookId: String, accountId: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a collection of webhooks.
    func all(accountId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Deletes a webhook having the given webhook ID.
    func delete(webhookId: String, accountId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `WebhookRoutes` protocol for Razorpay webhook operations.
public struct RazorpayWebhookRoutes: WebhookRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler

    init(client: RazorpayAPIHandler) {
        self.client = client
    }
    
    public func create(accountId: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = accountId.isEmpty ? "\(APIConstants.v1)\(APIConstants.webhook)" : "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.webhook)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(webhookId: String, accountId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.webhook)/\(webhookId)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func edit(webhookId: String, accountId: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = accountId.isEmpty ? "\(APIConstants.v1)\(APIConstants.webhook)/\(accountId)" : "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.webhook)/\(webhookId)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let method = accountId.isEmpty ? HTTPMethod.PUT : HTTPMethod.PATCH
        let response = try await client.sendRequest(method: method, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func all(accountId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = accountId.isEmpty ? "\(APIConstants.v1)\(APIConstants.webhook)" : "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.webhook)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func delete(webhookId: String, accountId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.webhook)/\(webhookId)"
        let response = try await client.sendRequest(method: .DELETE, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
