import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with orders in the Razorpay API.
public protocol OrderRoutes: RazorpayAPIRoute {
    
    /// Fetches all orders with optional query parameters and extra headers.
    /// - Parameters:
    ///   - queryParams: Optional query parameters to filter the orders.
    ///   - extraHeaders: Optional extra headers to include in the request.
    /// - Returns: A dictionary representing the fetched orders.
    func all(queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches an order by its ID.
    /// - Parameters:
    ///   - orderID: The ID of the order to fetch.
    ///   - queryParams: Optional query parameters to include in the request.
    ///   - extraHeaders: Optional extra headers to include in the request.
    /// - Returns: A dictionary representing the fetched order.
    func fetch(orderID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a new order with the given data.
    /// - Parameters:
    ///   - data: The data to be included in the request body for creating the order.
    ///   - extraHeaders: Optional extra headers to include in the request.
    /// - Returns: A dictionary representing the created order.
    func create(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Updates an existing order with the given data.
    /// - Parameters:
    ///   - orderID: The ID of the order to update.
    ///   - data: The data to be included in the request body for updating the order.
    ///   - extraHeaders: Optional extra headers to include in the request.
    /// - Returns: A dictionary representing the updated order.
    func update(orderID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches the payments associated with an order.
    /// - Parameters:
    ///   - orderID: The ID of the order to fetch payments for.
    ///   - queryParams: Optional query parameters to include in the request.
    ///   - extraHeaders: Optional extra headers to include in the request.
    /// - Returns: A dictionary representing the fetched payments.
    func payments(orderID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `OrderRoutes` protocol.
public struct RazorpayOrderRoutes: OrderRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler
    private let baseUrl: String

    init(client: RazorpayAPIHandler, baseUrl: String) {
        self.client = client
        self.baseUrl = baseUrl
    }
    
    // Fetches multiple orders for the given query parameters.
    public func all(queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let v1 = APIConstants.v1
        let url = "\(v1)\(APIConstants.orderURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
    
    // Fetches an order by ID.
    public func fetch(orderID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let v1 = APIConstants.v1
        let url = "\(v1)\(APIConstants.orderURL)/\(orderID)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
    
    // Creates a new order with the given data.
    public func create(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let v1 = APIConstants.v1
        let url = "\(v1)\(APIConstants.orderURL)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    // Updates an existing order with the given data.
    public func update(orderID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let v1 = APIConstants.v1
        let url = "\(v1)\(APIConstants.orderURL)/\(orderID)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
    
    // Fetches the payments associated with an order.
    public func payments(orderID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let v1 = APIConstants.v1
        let url = "\(v1)\(APIConstants.orderURL)/\(orderID)\(APIConstants.paymentURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
