import Testing
@testable import RazorpayKit
import NIO
import AsyncHTTPClient
import NIOHTTP1


struct RazorpayKitTests {
    var razorpayClient: RazorpayClient
    
    init() async throws {
        razorpayClient = RazorpayClient(httpClient: HTTPClient.shared, key: "RAZORPAY_KEY", secret: "RAZORPAY_SECRET")
    }
    
    // Tests fetching orders with associated payments
    // Verifies:
    // - Response contains valid items array
    // - Each item has a non-zero amount
    // - Total count matches items count
    @Test("Orders API")
    func ordersAreFetchedWithPayments() async throws {
        let response = try await razorpayClient.order.all(queryParams: ["expand[]":"payments"])
        
        #expect(response != nil)
        
        guard let items = response["items"] as? [[String: Any]] else {
            Issue.record("Items not found or invalid format")
            return
        }
        
        for item in items {
            guard let amount = item["amount"] as? Int else {
                Issue.record("Amount not found or invalid format in item: \(item)")
                continue
            }
            #expect(amount != 0, "Amount should not be zero")
        }
        
        if let expectedCount = response["count"] as? Int {
            #expect(items.count == expectedCount, "Fetched items count does not match expected count")
        }
    }

    // Tests order creation with standard parameters
    // Verifies:
    // - Order creation succeeds
    // - Response contains valid order ID
    @Test func createOrder() async throws {
        let orderData: [String: Any] = [
            "amount": 1000000,
            "currency": "INR", 
            "receipt": "Receipt no. 1",
            "notes": [
                "notes_key_1": "Tea, Earl Grey, Hot",
                "notes_key_2": "Tea, Earl Grey… decaf."
            ]
        ]
        let response = try await razorpayClient.order.create(data: orderData)
        #expect(response["id"] != nil, "Order should have an ID")
    }

    @Test func fetchOrder() async throws {
        let orderId = "order_MkGOjNTXK79HzQ"
        let response = try await razorpayClient.order.fetch(orderID: orderId)
        #expect(response["id"] as? String == orderId, "Fetched order ID should match the requested order ID")
    }

    @Test("Payments API")
    func fetchPayment() async throws {
        let paymentId = "pay_29QQoUBi66xm2f"
        let response = try await razorpayClient.payment.fetch(paymentID: paymentId)
        #expect(response["id"] as? String == paymentId, "Fetched payment ID should match the requested payment ID")
    }

    @Test func refundPayment() async throws {
        let paymentId = "pay_29QQoUBi66xm2f"
        let refundData: [String: Any] = ["amount": 100]
        let response = try await razorpayClient.payment.refund(paymentID: paymentId, amount: 100, data: refundData)
        #expect(response["id"] != nil, "Refund should have an ID")
    }
}
