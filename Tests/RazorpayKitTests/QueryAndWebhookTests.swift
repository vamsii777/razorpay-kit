import XCTest
import Foundation
import RazorpayKit
@testable import RazorpayCore
@testable import RazorpayLegacy
@testable import RazorpayVerification

final class QueryAndWebhookTests: XCTestCase {
    private func makeClient(_ mock: MockTransport) -> RazorpayClient {
        RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
    }

    func testQueryStringEncodesReservedCharactersAndSortsKeys() {
        let query = RZPRUTL.convertToQueryString([
            "skip": "0",
            "expand[]": "card",
            "notes": "a b&c=d+e/f?",
            "count": "10",
        ])
        XCTAssertEqual(query, "?count=10&expand%5B%5D=card&notes=a%20b%26c%3Dd%2Be%2Ff%3F&skip=0")
    }

    func testQueryStringIsDeterministic() {
        let params = (0..<20).reduce(into: [String: String]()) { $0["k\($1)"] = "v\($1)" }
        let first = RZPRUTL.convertToQueryString(params)
        for _ in 0..<10 {
            XCTAssertEqual(RZPRUTL.convertToQueryString(params), first)
        }
    }

    func testEmptyQueryProducesNoQuestionMark() {
        XCTAssertEqual(RZPRUTL.convertToQueryString(nil), "")
        XCTAssertEqual(RZPRUTL.convertToQueryString([:]), "")
    }

    func testRequestURLUsesEncodedQueryViaTransport() async throws {
        let mock = MockTransport(json: #"{"entity":"collection","count":0,"items":[]}"#)
        _ = try await RazorpayPaymentRoutes(client: makeClient(mock).handler).all(queryParams: ["expand[]": "card", "from": "1 2"], extraHeaders: nil)
        let requestValue = await mock.lastRequest
        let request = try XCTUnwrap(requestValue)
        XCTAssertEqual(request.url, "https://api.razorpay.com/v1/payments?expand%5B%5D=card&from=1%202")
    }

    func testWebhookEditV1UsesWebhookId() async throws {
        let mock = MockTransport(json: #"{"id":"wh_TEST"}"#)
        _ = try await RazorpayWebhookRoutes(client: makeClient(mock).handler).edit(webhookId: "wh_TEST", accountId: "", data: ["url": "https://example.com/hook"], extraHeaders: nil)
        let requestValue = await mock.lastRequest
        let request = try XCTUnwrap(requestValue)
        XCTAssertEqual(request.method, .PUT)
        XCTAssertEqual(request.path, "/v1/webhooks/wh_TEST")
        let body = try XCTUnwrap(try MockTransport.json(request.body))
        XCTAssertEqual(body["url"] as? String, "https://example.com/hook")
    }

    func testWebhookEditV2UsesAccountAndWebhookId() async throws {
        let mock = MockTransport(json: #"{"id":"wh_TEST"}"#)
        _ = try await RazorpayWebhookRoutes(client: makeClient(mock).handler).edit(webhookId: "wh_TEST", accountId: "acc_TEST", data: ["active": true], extraHeaders: nil)
        let requestValue = await mock.lastRequest
        let request = try XCTUnwrap(requestValue)
        XCTAssertEqual(request.method, .PATCH)
        XCTAssertEqual(request.path, "/v2/accounts/acc_TEST/webhooks/wh_TEST")
    }
}
