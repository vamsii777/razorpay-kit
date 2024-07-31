import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with stakeholders in the Razorpay API.
public protocol StakeholderRoutes: RazorpayAPIRoute {
    
    /// Creates a new stakeholder for the given data.
    func create(accountId: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a stakeholder by their accountId and stakeholderId.
    func fetch(accountId: String, stakeholderId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a collection of stakeholders for the given accountId.
    func all(accountId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Updates a stakeholder by their accountId and stakeholderId.
    func edit(accountId: String, stakeholderId: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Uploads stakeholder documents.
    func uploadStakeholderDoc(accountId: String, stakeholderId: String, params: FileUploadParams, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches the stakeholder documents.
    func fetchStakeholderDoc(accountId: String, stakeholderId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `StakeholderRoutes` protocol for Razorpay stakeholder operations.
public struct RazorpayStakeholderRoutes: StakeholderRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler

    init(client: RazorpayAPIHandler) {
        self.client = client
    }
    
    public func create(accountId: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.stakeholderURL)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(accountId: String, stakeholderId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.stakeholderURL)/\(stakeholderId)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func all(accountId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.stakeholderURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func edit(accountId: String, stakeholderId: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)\(APIConstants.stakeholderURL)/\(stakeholderId)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .PATCH, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    @available(*, deprecated, message: "This function is under development and cannot be used.")
    public func uploadStakeholderDoc(accountId: String, stakeholderId: String, params: FileUploadParams, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)/stakeholders/\(stakeholderId)/documents"
        // This method needs to be implemented based on your specific file upload handling in Swift.
        fatalError("File upload functionality needs custom implementation based on your app's needs.")
    }

    public func fetchStakeholderDoc(accountId: String, stakeholderId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v2)\(APIConstants.accountURL)/\(accountId)/stakeholders/\(stakeholderId)/documents"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
