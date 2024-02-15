import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with accounts in the Razorpay API.
public protocol AccountRoutes: RazorpayAPIRoute {
    
    /// Creates a new account with the given data.
    func create(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches an account by its ID.
    func fetch(accountId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Updates an account by its ID with the given data.
    func edit(accountId: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Deletes an account by its ID.
    func delete(accountId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Uploads account documents.
    func uploadAccountDoc(accountId: String, params: FileUploadParams, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches account documents.
    func fetchAccountDoc(accountId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `AccountRoutes` protocol for Razorpay account operations.
public struct RazorpayAccountRoutes: AccountRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler
    private let baseUrl: String

    init(client: RazorpayAPIHandler, baseUrl: String) {
        self.client = client
        self.baseUrl = baseUrl
    }
    
    public func create(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(accountId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func edit(accountId: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .PATCH, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func delete(accountId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)"
        let response = try await client.sendRequest(method: .DELETE, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    
    @available(*, deprecated, message: "This function is under development and cannot be used.")
    public func uploadAccountDoc(accountId: String, params: FileUploadParams, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)/documents"
        fatalError("File upload functionality needs custom implementation based on your app's needs.")
    }

    public func fetchAccountDoc(accountId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)/documents"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}

/// Represents parameters for file upload, this will need to be defined based on how your application handles file uploads.
public struct FileUploadParams {
    // Define properties based on your file upload requirements.
}
