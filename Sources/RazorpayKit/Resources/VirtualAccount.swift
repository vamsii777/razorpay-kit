import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with virtual accounts in the Razorpay API.
public protocol VirtualAccountRoutes: RazorpayAPIRoute {
    
    /// Fetches a collection of virtual accounts for the given query parameters.
    func all(queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a virtual account by its ID.
    func fetch(virtualAccID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a new virtual account for the given data.
    func create(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Closes the virtual account having the given ID.
    func close(virtualAccID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a collection of payments associated with the virtual account having the given ID.
    func payments(virtualAccID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Adds a receiver to an existing virtual account by virtual ID and data.
    func addReceiver(virtualAccID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Adds allowed payer's account detail by virtual ID and data.
    func allowedPayer(virtualAccID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Deletes allowed payer's account details by virtual ID and payer ID.
    func deleteAllowedPayer(virtualAccID: String, payerId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `VirtualAccountRoutes` protocol for Razorpay virtual account operations.
public struct RazorpayVirtualAccountRoutes: VirtualAccountRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler

    init(client: RazorpayAPIHandler) {
        self.client = client
    }
    
    public func all(queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.virtualAccountURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(virtualAccID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.virtualAccountURL)/\(virtualAccID)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func create(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.virtualAccountURL)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func close(virtualAccID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.virtualAccountURL)/\(virtualAccID)/close"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func payments(virtualAccID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.virtualAccountURL)/\(virtualAccID)/payments"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func addReceiver(virtualAccID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.virtualAccountURL)/\(virtualAccID)/receivers"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func allowedPayer(virtualAccID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.virtualAccountURL)/\(virtualAccID)/allowed_payers"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func deleteAllowedPayer(virtualAccID: String, payerId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.virtualAccountURL)/\(virtualAccID)/allowed_payers/\(payerId)"
        let response = try await client.sendRequest(method: .DELETE, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
