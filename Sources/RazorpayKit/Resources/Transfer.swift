import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with transfers in the Razorpay API.
public protocol TransferRoutes: RazorpayAPIRoute {
    
    /// Fetches a collection of transfers for the given query parameters.
    func all(queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a transfer by its ID.
    func fetch(transferID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a new transfer for the given data.
    func create(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Edits the transfer having the given transferID.
    func edit(transferID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Reverses the transfer having the given transferID.
    func reverse(transferID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a collection of reversals associated with the given transferID.
    func reversals(transferID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `TransferRoutes` protocol for Razorpay transfer operations.
public struct RazorpayTransferRoutes: TransferRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler

    init(client: RazorpayAPIHandler) {
        self.client = client
    }
    
    public func all(queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.transferURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(transferID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.transferURL)/\(transferID)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func create(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.transferURL)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func edit(transferID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.transferURL)/\(transferID)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .PATCH, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func reverse(transferID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.transferURL)/\(transferID)/reversals"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func reversals(transferID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.transferURL)/\(transferID)/reversals"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
