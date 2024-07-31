import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with tokens in the Razorpay API.
public protocol TokenRoutes: RazorpayAPIRoute {
    
    /// Creates a new token for the given data.
    func create(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a token by its ID associated with a customer ID.
    func fetch(customerID: String, tokenID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a collection of tokens associated with a customer ID.
    func all(customerID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Deletes a token by its ID associated with a customer ID.
    func delete(customerID: String, tokenID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches card properties of an existing token.
    func fetchCardPropertiesByToken(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Deletes a token.
    func deleteToken(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Processes a payment on the tokenised card on another PA/PG with token created on Razorpay.
    func processPaymentOnAlternatePAorPG(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `TokenRoutes` protocol for Razorpay token operations.
public struct RazorpayTokenRoutes: TokenRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler

    init(client: RazorpayAPIHandler) {
        self.client = client
    }
    
    public func create(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)/tokens"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(customerID: String, tokenID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.customerURL)/\(customerID)/tokens/\(tokenID)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func all(customerID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.customerURL)/\(customerID)/tokens"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func delete(customerID: String, tokenID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.customerURL)/\(customerID)/tokens/\(tokenID)"
        let response = try await client.sendRequest(method: .DELETE, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetchCardPropertiesByToken(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)/tokens/fetch"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func deleteToken(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)/tokens/delete"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func processPaymentOnAlternatePAorPG(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)/tokens/service_provider_tokens/token_transactional_data"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
