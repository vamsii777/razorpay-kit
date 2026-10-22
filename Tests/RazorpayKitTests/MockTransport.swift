import Foundation
import NIOHTTP1
import RazorpayKit
@testable import RazorpayCore
@testable import RazorpayVerification

/// A transport that never touches the network. It records each request and returns canned
/// responses. Keep this file identical in every test target.
actor MockTransport: RazorpayTransport {
    typealias Responder = @Sendable (RazorpayHTTPRequest) throws -> RazorpayHTTPResponse

    private(set) var requests: [RazorpayHTTPRequest] = []
    private var responder: Responder

    init(status: HTTPResponseStatus = .ok, json: String = "{}") {
        self.responder = { _ in RazorpayHTTPResponse(status: status, body: Data(json.utf8)) }
    }

    init(responder: @escaping Responder) {
        self.responder = responder
    }

    func send(_ request: RazorpayHTTPRequest) async throws -> RazorpayHTTPResponse {
        requests.append(request)
        return try responder(request)
    }

    var lastRequest: RazorpayHTTPRequest? { requests.last }

    /// Decodes a request body as a JSON object.
    static func json(_ body: Data?) throws -> [String: Any]? {
        guard let body else { return nil }
        return try JSONSerialization.jsonObject(with: body) as? [String: Any]
    }
}

enum TestKeys {
    /// Placeholders only. Never put real keys here.
    static let key = "rzp_test_XXXXXXXX"
    static let secret = "test_secret_placeholder"
}
