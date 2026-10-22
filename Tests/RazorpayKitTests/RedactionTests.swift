import AsyncHTTPClient
import Foundation
import Testing
import RazorpayKit
@testable import RazorpayCore
@testable import RazorpayVerification

// Placeholder credentials only; no network calls are made.
@Suite("Secret redaction")
struct RedactionTests {
    static let key = "rzp_test_XXXXXXXX"
    static let secret = "PLACEHOLDER_SECRET_value"
    static var auth: String { RazorpayAPIHandler.basicAuthorization(key: key, secret: secret) }

    func assertRedacted(_ text: String, sourceLocation: SourceLocation = #_sourceLocation) {
        #expect(!text.contains(Self.secret), sourceLocation: sourceLocation)
        #expect(!text.contains(Self.key), sourceLocation: sourceLocation)
        #expect(!text.contains(String(Self.auth.dropFirst("Basic ".count))), sourceLocation: sourceLocation)
    }

    @Test func clientIsRedacted() {
        let client = RazorpayClient(HTTPClient.shared, key: Self.key, secret: Self.secret)
        assertRedacted(String(describing: client))
        assertRedacted(String(reflecting: client))
        assertRedacted("\(client)")
        var dumped = ""
        dump(client, to: &dumped)
        assertRedacted(dumped)
        #expect(String(describing: client).contains("<redacted>"))
    }

    @Test func handlerIsRedacted() {
        let handler = RazorpayAPIHandler(transport: AsyncHTTPClientTransport(httpClient: HTTPClient.shared), key: Self.key, secret: Self.secret)
        assertRedacted(String(describing: handler))
        assertRedacted(String(reflecting: handler))
        var dumped = ""
        dump(handler, to: &dumped)
        assertRedacted(dumped)
        for child in Mirror(reflecting: handler).children {
            assertRedacted(String(describing: child.value))
        }
    }

    @Test func authorizationHeaderIsBasic() {
        let expected = "Basic " + Data("\(Self.key):\(Self.secret)".utf8).base64EncodedString()
        #expect(Self.auth == expected)
    }
}
