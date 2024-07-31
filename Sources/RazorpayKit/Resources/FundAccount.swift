import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with fund accounts in the Razorpay API.
public protocol FundAccountRoutes: RazorpayAPIRoute {
    
    /// Fetches all fund accounts with optional query parameters and extra headers.
    func all(queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a fund account with the given data.
    func create(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `FundAccountRoutes` protocol for Razorpay fund account operations.
public struct RazorpayFundAccountRoutes: FundAccountRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler

    init(client: RazorpayAPIHandler) {
        self.client = client
    }
    
    public func all(queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.fundAccountURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func create(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.fundAccountURL)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
