import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with invoices in the Razorpay API.
public protocol InvoiceRoutes: RazorpayAPIRoute {
    
    /// Fetches multiple invoices for the given query parameters.
    func all(queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches an invoice by its ID.
    func fetch(invoiceID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a new invoice with the given data.
    func create(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Cancels an invoice by its ID.
    func cancel(invoiceID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Deletes a draft invoice by its ID.
    func delete(invoiceID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Updates an invoice by its ID with the given data.
    func update(invoiceID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Issues an invoice by its ID.
    func issue(invoiceID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Notifies a customer via email or SMS for the given invoice ID.
    func notify(invoiceID: String, medium: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a registration link.
    func createRegistrationLink(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `InvoiceRoutes` protocol for Razorpay invoice operations.
public struct RazorpayInvoiceRoutes: InvoiceRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler

    init(client: RazorpayAPIHandler) {
        self.client = client
    }
    
    public func all(queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.invoiceURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(invoiceID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.invoiceURL)/\(invoiceID)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func create(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.invoiceURL)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func cancel(invoiceID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.invoiceURL)/\(invoiceID)/cancel"
        let response = try await client.sendRequest(method: .POST, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func delete(invoiceID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.invoiceURL)/\(invoiceID)"
        let response = try await client.sendRequest(method: .DELETE, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func update(invoiceID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.invoiceURL)/\(invoiceID)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .PATCH, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func issue(invoiceID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.invoiceURL)/\(invoiceID)/issue"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func notify(invoiceID: String, medium: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.invoiceURL)/\(invoiceID)/notify_by/\(medium)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func createRegistrationLink(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)/subscription_registration/auth_links"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
