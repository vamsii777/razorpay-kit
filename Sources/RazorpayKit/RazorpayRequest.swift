import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1
import AsyncHTTPClient


extension HTTPClientRequest.Body {
    public static func string(_ string: String) -> Self {
        .bytes(.init(string: string))
    }
    
    public static func data(_ data: Data) -> Self {
        .bytes(.init(data: data))
    }

    public static func json(_ json: [String: Any]) throws -> Self {
        .bytes(.init(data: try JSONSerialization.data(withJSONObject: json, options: [])))
    }
}

struct RazorpayAPIHandler {
    private let httpClient: HTTPClient
    /// Precomputed `Basic` credentials. Never exposed via description, mirror or errors.
    private let authorization: String

    public init(httpClient: HTTPClient, key: String, secret: String) {
        self.httpClient = httpClient
        self.authorization = Self.basicAuthorization(key: key, secret: secret)
    }

    static func basicAuthorization(key: String, secret: String) -> String {
        "Basic " + Data("\(key):\(secret)".utf8).base64EncodedString()
    }

    private func authorizationHeader() -> String {
        authorization
    }

    public func sendRequest(method: HTTPMethod,
                            path: String,
                            queryParams: [String: String]? = nil,
                            body: HTTPClientRequest.Body? = nil,
                            headers: HTTPHeaders) async throws -> HTTPClientResponse {
        
        let queryString = RZPRUTL.convertToQueryString(queryParams)
        let url = APIConstants.baseURL + path + queryString
        
        var requestHeaders: HTTPHeaders = [
            "Authorization": authorizationHeader(),
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        headers.forEach { requestHeaders.add(name: $0.name, value: $0.value) }

        var request = HTTPClientRequest(url: url)
        request.method = method
        request.headers = requestHeaders
        request.body = body
        
        let response = try await httpClient.execute(request, timeout: .seconds(60))
        return response
    }
}

extension RazorpayAPIHandler: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    var description: String { "RazorpayAPIHandler(credentials: <redacted>)" }
    var debugDescription: String { description }
    var customMirror: Mirror { Mirror(self, children: ["credentials": "<redacted>"], displayStyle: .struct) }
}
