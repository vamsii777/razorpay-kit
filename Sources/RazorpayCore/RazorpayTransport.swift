import Foundation
import NIOCore
import NIOHTTP1
import AsyncHTTPClient

/// An HTTP request ready to send to the Razorpay API.
///
/// `path` is relative to the fixed base URL `https://api.razorpay.com`, for example `/v1/orders`.
/// See https://razorpay.com/docs/api.
public struct RazorpayHTTPRequest: Sendable {
    /// The HTTP method.
    public var method: HTTPMethod
    /// The path relative to `https://api.razorpay.com`, for example `/v1/orders`.
    public var path: String
    /// The query parameters, not yet encoded.
    public var query: [String: String]
    /// The request headers, including `Authorization`.
    public var headers: HTTPHeaders
    /// The request body, if there is one.
    public var body: Data?

    /// Creates a request.
    public init(method: HTTPMethod, path: String, query: [String: String] = [:], headers: HTTPHeaders = [:], body: Data? = nil) {
        self.method = method
        self.path = path
        self.query = query
        self.headers = headers
        self.body = body
    }

    /// The full URL: `https://api.razorpay.com` + path + encoded query.
    public var url: String {
        APIConstants.baseURL + path + RZPRUTL.convertToQueryString(query)
    }
}

/// A raw HTTP response from the Razorpay API.
public struct RazorpayHTTPResponse: Sendable {
    /// The HTTP status.
    public var status: HTTPResponseStatus
    /// The response headers.
    public var headers: HTTPHeaders
    /// The response body.
    public var body: Data

    /// Creates a response.
    public init(status: HTTPResponseStatus, headers: HTTPHeaders = [:], body: Data = Data()) {
        self.status = status
        self.headers = headers
        self.body = body
    }
}

/// Sends HTTP requests to the Razorpay API.
///
/// The default is ``AsyncHTTPClientTransport``. Inject your own transport, such as a mock in
/// tests, through ``RazorpayClient/init(transport:key:secret:webhookSecret:)``. See https://razorpay.com/docs/api.
public protocol RazorpayTransport: Sendable {
    /// Sends a request and returns the raw response. Non-2xx statuses are returned, not thrown.
    func send(_ request: RazorpayHTTPRequest) async throws -> RazorpayHTTPResponse
}

/// The default ``RazorpayTransport``. It is backed by AsyncHTTPClient and always uses HTTPS to
/// `https://api.razorpay.com`. See https://razorpay.com/docs/api.
public struct AsyncHTTPClientTransport: RazorpayTransport {
    private let httpClient: HTTPClient
    private let timeout: TimeAmount

    /// Creates a transport.
    /// - Parameters:
    ///   - httpClient: The client to use. Defaults to `HTTPClient.shared`.
    ///   - timeout: The per-request timeout. Defaults to 60 seconds.
    public init(httpClient: HTTPClient = .shared, timeout: TimeAmount = .seconds(60)) {
        self.httpClient = httpClient
        self.timeout = timeout
    }

    public func send(_ request: RazorpayHTTPRequest) async throws -> RazorpayHTTPResponse {
        var http = HTTPClientRequest(url: request.url)
        http.method = request.method
        http.headers = request.headers
        if let body = request.body {
            http.body = .bytes(ByteBuffer(bytes: body))
        }
        let response = try await httpClient.execute(http, timeout: timeout)
        let buffer = try await response.body.collect(upTo: 10 * 1024 * 1024)
        return RazorpayHTTPResponse(
            status: response.status,
            headers: response.headers,
            body: Data(buffer.readableBytesView)
        )
    }
}
