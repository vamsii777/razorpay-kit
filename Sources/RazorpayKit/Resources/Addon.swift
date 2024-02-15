import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with addons in the Razorpay API.
public protocol AddonRoutes: RazorpayAPIRoute {
    
    /// Fetches an addon by its ID.
    func fetch(addonID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Deletes an addon by its ID.
    func delete(addonID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches all addons with optional query parameters and extra headers.
    func all(queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `AddonRoutes` protocol for Razorpay addon operations.
public struct RazorpayAddonRoutes: AddonRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler
    private let baseUrl: String

    init(client: RazorpayAPIHandler, baseUrl: String) {
        self.client = client
        self.baseUrl = baseUrl
    }
    
    public func fetch(addonID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.addonURL)/\(addonID)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func delete(addonID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.addonURL)/\(addonID)"
        let response = try await client.sendRequest(method: .DELETE, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func all(queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.addonURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
