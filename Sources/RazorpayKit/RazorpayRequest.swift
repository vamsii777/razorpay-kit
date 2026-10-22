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

struct RazorpayAPIHandler: Sendable {
    private let transport: any RazorpayTransport
    private let key: String
    private let secret: String

    init(transport: any RazorpayTransport, key: String, secret: String) {
        self.transport = transport
        self.key = key
        self.secret = secret
    }

    private func authorizationHeader() -> String {
        "Basic " + Data("\(key):\(secret)".utf8).base64EncodedString()
    }

    func sendRequest(method: HTTPMethod,
                     path: String,
                     queryParams: [String: String]? = nil,
                     body: Data? = nil,
                     headers: HTTPHeaders) async throws -> RazorpayHTTPResponse {
        var requestHeaders: HTTPHeaders = [
            "Authorization": authorizationHeader(),
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        headers.forEach { requestHeaders.add(name: $0.name, value: $0.value) }
        let request = RazorpayHTTPRequest(
            method: method,
            path: path,
            query: queryParams ?? [:],
            headers: requestHeaders,
            body: body
        )
        return try await transport.send(request)
    }
}
