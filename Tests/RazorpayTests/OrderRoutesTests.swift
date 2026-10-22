import XCTest
import Foundation
@testable import RazorpayKit
@testable import Razorpay

final class OrderRoutesTests: XCTestCase {
    func testFetchOrderDecodesResponse() async throws {
        let json = #"{"id":"order_TEST","entity":"order","amount":50000,"amount_paid":0,"amount_due":50000,"currency":"INR","receipt":"r1","status":"created","attempts":0,"notes":[],"created_at":1700000000}"#
        let mock = MockTransport(json: json)
        let razorpay = Razorpay(RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret))
        let order = try await razorpay.orders.fetch(id: "order_TEST")
        XCTAssertEqual(order.id, "order_TEST")
        XCTAssertEqual(order.amount, 50000)
        let requestValue = await mock.lastRequest
        let request = try XCTUnwrap(requestValue)
        XCTAssertEqual(request.method, .GET)
        XCTAssertEqual(request.path, "/v1/orders/order_TEST")
    }

    func testCreateOrderBelowMinimumThrowsWithoutRequest() async throws {
        let mock = MockTransport()
        let razorpay = Razorpay(RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret))
        do {
            _ = try await razorpay.orders.create(amount: 99, currency: .indianRupee, receipt: nil, notes: nil)
            XCTFail("expected validation error")
        } catch is RazorpayError {
        }
        let count = await mock.requests.count
        XCTAssertEqual(count, 0)
    }
}
