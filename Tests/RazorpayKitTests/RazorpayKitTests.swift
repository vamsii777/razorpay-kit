import XCTest
@testable import RazorpayKit
import NIO
import AsyncHTTPClient

// TODO: Create mock server with all the tests
final class RazorpayKitTests: XCTestCase {
    var razorpayClient: RazorpayClient!
    var httpClient: HTTPClient!
    
    override func setUp() {
        super.setUp()
        httpClient = HTTPClient(eventLoopGroupProvider: .singleton)
        razorpayClient = RazorpayClient(httpClient: httpClient, key: "RAZORPAY_KEY", secret: "RAZORPAY_SECRET")
    }
    
    func testThatOrdersAreFetchedWithPayments() async throws {
        let response = try await razorpayClient.order.all(queryParams: ["expand[]":"payments"])
        print("Response: \(response)")
        XCTAssertNotNil(response)
        
        // Assuming `response` is a dictionary with a key "items" that contains an array of order dictionaries
        guard let items = response["items"] as? [[String: Any]] else {
            XCTFail("Items not found or invalid format")
            return
        }
        
        // Iterate through each item and extract the amount
        for item in items {
            guard let amount = item["amount"] as? Int else {
                XCTFail("Amount not found or invalid format in item: \(item)")
                continue
            }
            // Perform your test on the amount here - for example, checking it's not zero
            XCTAssertNotEqual(amount, 0, "Amount should not be zero")
        }
        
        // If needed, test the count of items
        let expectedCount = response["count"] as? Int
        XCTAssertEqual(items.count, expectedCount, "Fetched items count does not match expected count")
    }
    
    func testCreateOrder() async throws {
        let orderData: [String: Any] = [
            "amount": 1000000, // amount in the smallest currency unit, for example, 1000000 paise = 10000 INR
            "currency": "INR",
            "receipt": "Receipt no. 1",
            "notes": [
                "notes_key_1": "Tea, Earl Grey, Hot",
                "notes_key_2": "Tea, Earl Grey… decaf."
            ]
        ]
        let response = try await razorpayClient.order.create(data: orderData)
        XCTAssertNotNil(response["id"], "Order should have an ID")
    }
    
    func testFetchOrder() async throws {
        let orderId = "order_MkGOjNTXK79HzQ"
        let response = try await razorpayClient.order.fetch(orderID: orderId)
        XCTAssertEqual(response["id"] as? String, orderId, "Fetched order ID should match the requested order ID")
    }
    
    func testFetchPayment() async throws {
        let paymentId = "pay_29QQoUBi66xm2f"
        let response = try await razorpayClient.payment.fetch(paymentID: paymentId)
        XCTAssertEqual(response["id"] as? String, paymentId, "Fetched payment ID should match the requested payment ID")
    }
    
    func testRefundPayment() async throws {
        let paymentId = "pay_29QQoUBi66xm2f"
        let refundData: [String: Any] = ["amount": 100] // Refund amount in the smallest currency unit.
        let response = try await razorpayClient.payment.refund(paymentID: paymentId, amount: 100, data: refundData)
        XCTAssertNotNil(response["id"], "Refund should have an ID")
    }
}
