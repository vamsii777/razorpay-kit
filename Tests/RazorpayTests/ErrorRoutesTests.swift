import XCTest
import Foundation
@testable import RazorpayKit
@testable import Razorpay

final class ErrorRoutesTests: XCTestCase {
    func testTypedRoutesThrowOnNon2xx() async throws {
        for (status, body) in [
            (400, #"{"error":{"code":"BAD_REQUEST_ERROR","description":"bad"}}"#),
            (401, #"{"error":{"code":"BAD_REQUEST_ERROR","description":"Authentication failed"}}"#),
            (404, #"{"error":{"code":"BAD_REQUEST_ERROR","description":"not found"}}"#),
            (429, #"{"error":{"code":"RATE_LIMITED","description":"slow down"}}"#),
            (500, #"{"error":{"code":"SERVER_ERROR","description":"oops"}}"#),
            (500, "garbage"),
        ] {
            let mock = MockTransport(status: .init(statusCode: status), json: body)
            let razorpay = Razorpay(RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret))
            do {
                _ = try await razorpay.orders.fetch(id: "order_TEST")
                XCTFail("HTTP \(status) should throw")
            } catch let error as RazorpayError {
                XCTAssertEqual(error.statusCode, status, "body: \(body)")
            }
        }
    }
}
