import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with products in the Razorpay API.
public protocol ProductRoutes: RazorpayAPIRoute {
    
    /// Requests a product configuration for the given data.
    func requestProductConfiguration(accountId: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches the details of a product.
    func fetch(accountId: String, productId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Updates the product's configuration.
    func edit(accountId: String, productId: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches the terms and conditions.
    func fetchTnc(productname: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `ProductRoutes` protocol for Razorpay product operations.
public struct RazorpayProductRoutes: ProductRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler

    init(client: RazorpayAPIHandler) {
        self.client = client
    }
    
    public func requestProductConfiguration(accountId: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.productURL)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(accountId: String, productId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.productURL)/\(productId)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func edit(accountId: String, productId: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.productURL)/\(productId)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .PATCH, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetchTnc(productname: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.productURL)/\(productname)\(APIConstants.tnc)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
