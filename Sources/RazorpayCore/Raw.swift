import Foundation
import NIOHTTP1

extension RazorpayClient {
    /// An escape hatch for endpoints the typed API does not cover yet. It shares authentication,
    /// headers, error mapping and typed throws with the rest of the SDK.
    ///
    /// ```swift
    /// let plan = try await razorpay.raw.get("/v1/plans/plan_123")          // JSONValue
    /// let item: MyItem = try await razorpay.raw.send(.POST, "/v1/items",
    ///                                                 body: ["name": "Book", "amount": 500])
    /// ```
    public var raw: Raw { Raw(handler: handler) }

    /// See ``RazorpayClient/raw``.
    public struct Raw: Sendable {
        let handler: RazorpayAPIHandler

        /// Paths must be relative to `https://api.razorpay.com` and start with `/`, for example
        /// `/v1/plans`. Absolute URLs and `//host` paths are rejected so a request can never
        /// leave the Razorpay host.
        static func validate(_ path: String) -> Result<String, RazorpayError> {
            guard path.hasPrefix("/"), !path.hasPrefix("//"), !path.contains("://"), !path.contains("?") else {
                return .failure(.invalidRequest("raw path must be relative, like /v1/plans, with the query passed separately; got \(path)"))
            }
            return .success(path)
        }
    }
}

#if compiler(>=6.0)
extension RazorpayClient.Raw {
    /// Sends any request and decodes the response into `type` (``JSONValue`` by default).
    public func send<Response: Decodable>(
        _ method: HTTPMethod, _ path: String, query: [String: String] = [:], body: JSONValue? = nil,
        options: RequestOptions = .init(), as type: Response.Type = JSONValue.self
    ) async throws(RazorpayError) -> Response {
        try await handler.perform(method, Self.validate(path).get(), query: query, body: body, options: options, as: type)
    }

    /// `GET` returning ``JSONValue``.
    public func get(_ path: String, query: [String: String] = [:], options: RequestOptions = .init()) async throws(RazorpayError) -> JSONValue {
        try await send(.GET, path, query: query, options: options)
    }
}
#else
extension RazorpayClient.Raw {
    /// Sends any request and decodes the response into `type` (``JSONValue`` by default).
    public func send<Response: Decodable>(
        _ method: HTTPMethod, _ path: String, query: [String: String] = [:], body: JSONValue? = nil,
        options: RequestOptions = .init(), as type: Response.Type = JSONValue.self
    ) async throws -> Response {
        try await handler.perform(method, Self.validate(path).get(), query: query, body: body, options: options, as: type)
    }

    /// `GET` returning ``JSONValue``.
    public func get(_ path: String, query: [String: String] = [:], options: RequestOptions = .init()) async throws -> JSONValue {
        try await send(.GET, path, query: query, options: options)
    }
}
#endif
