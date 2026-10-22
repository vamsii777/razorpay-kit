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

package struct RazorpayAPIHandler: Sendable {
    private let transport: any RazorpayTransport
    /// Precomputed `Basic` credentials. Never exposed via description, mirror or errors.
    private let authorization: String

    package init(transport: any RazorpayTransport, key: String, secret: String) {
        self.transport = transport
        self.authorization = Self.basicAuthorization(key: key, secret: secret)
    }

    package static func basicAuthorization(key: String, secret: String) -> String {
        "Basic " + Data("\(key):\(secret)".utf8).base64EncodedString()
    }

    private func authorizationHeader() -> String {
        authorization
    }

    package func sendRequest(method: HTTPMethod,
                     path: String,
                     queryParams: [String: String]? = nil,
                     body: Data? = nil,
                     headers: HTTPHeaders) async throws -> RazorpayHTTPResponse {
        var requestHeaders: HTTPHeaders = [
            "Authorization": authorizationHeader(),
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        headers.forEach { header in
            guard header.name.lowercased() != "authorization" else { return }
            requestHeaders.replaceOrAdd(name: header.name, value: header.value)
        }
        let request = RazorpayHTTPRequest(
            method: method,
            path: path,
            query: queryParams ?? [:],
            headers: requestHeaders,
            body: body
        )
        do {
            return try await transport.send(request)
        } catch {
            throw RazorpayError.wrap(error)
        }
    }
}

extension RazorpayAPIHandler: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package var description: String { "RazorpayAPIHandler(credentials: <redacted>)" }
    package var debugDescription: String { description }
    package var customMirror: Mirror { Mirror(self, children: ["credentials": "<redacted>"], displayStyle: .struct) }
}
