import XCTest
import Foundation
import NIOHTTP1
@testable import RazorpayKit

final class TransportTests: XCTestCase {
    private func makeClient(_ mock: MockTransport) -> RazorpayClient {
        RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
    }

    func testCreateOrderSendsMethodPathAndBody() async throws {
        let mock = MockTransport(json: #"{"id":"order_TEST","entity":"order"}"#)
        let client = makeClient(mock)
        let result = try await client.order.create(data: ["amount": 50000, "currency": "INR"], extraHeaders: nil)
        XCTAssertEqual(result["id"] as? String, "order_TEST")

        let requestValue = await mock.lastRequest
        let request = try XCTUnwrap(requestValue)
        XCTAssertEqual(request.method, .POST)
        XCTAssertEqual(request.path, "/v1/orders")
        XCTAssertEqual(request.query, [:])
        let bodyValue = try MockTransport.json(request.body)
        let body = try XCTUnwrap(bodyValue)
        XCTAssertEqual(body["amount"] as? Int, 50000)
        XCTAssertEqual(body["currency"] as? String, "INR")
    }

    func testFetchSendsQueryParameters() async throws {
        let mock = MockTransport(json: #"{"entity":"collection","count":0,"items":[]}"#)
        let client = makeClient(mock)
        _ = try await client.order.all(queryParams: ["count": "10", "skip": "0"], extraHeaders: nil)

        let requestValue = await mock.lastRequest
        let request = try XCTUnwrap(requestValue)
        XCTAssertEqual(request.method, .GET)
        XCTAssertEqual(request.path, "/v1/orders")
        XCTAssertEqual(request.query, ["count": "10", "skip": "0"])
        XCTAssertNil(request.body)
    }

    func testRequestsUseFixedHTTPSBaseURLAndBasicAuth() async throws {
        let mock = MockTransport()
        let client = makeClient(mock)
        _ = try await client.order.fetch(orderID: "order_TEST", queryParams: nil, extraHeaders: ["X-Test": "1"])

        let requestValue = await mock.lastRequest
        let request = try XCTUnwrap(requestValue)
        XCTAssertTrue(request.url.hasPrefix("https://api.razorpay.com/v1/orders/order_TEST"))
        let auth = try XCTUnwrap(request.headers.first(name: "Authorization"))
        let expected = Data("\(TestKeys.key):\(TestKeys.secret)".utf8).base64EncodedString()
        XCTAssertEqual(auth, "Basic \(expected)")
        XCTAssertEqual(request.headers.first(name: "X-Test"), "1")
        XCTAssertEqual(request.headers.first(name: "Accept"), "application/json")
    }

    func testTransportErrorsPropagate() async throws {
        struct Boom: Error {}
        let mock = MockTransport { _ in throw Boom() }
        let client = makeClient(mock)
        do {
            _ = try await client.order.fetch(orderID: "order_TEST", queryParams: nil, extraHeaders: nil)
            XCTFail("expected an error")
        } catch is Boom {
        }
    }
}
