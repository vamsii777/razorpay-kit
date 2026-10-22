import Foundation
import Testing
@testable import RazorpayKit

/// Keeps the README and DocC snippets compiling and behaving.
@Suite("Doc examples")
struct DocExampleTests {
    @Test func quickStartFlow() async throws {
        let mock = MockTransport { request in
            switch request.path {
            case "/v1/orders": return RazorpayHTTPResponse(status: .ok, body: Data(Fixtures.order.utf8))
            case "/v1/payments/pay_TEST000001/capture": return RazorpayHTTPResponse(status: .ok, body: Data(Fixtures.payment.utf8))
            default: return RazorpayHTTPResponse(status: .ok, body: Data(Fixtures.collection([Fixtures.refund]).utf8))
            }
        }
        let razorpay = RazorpayClient(transport: mock, key: TestKeys.key, secret: "test_key_secret", webhookSecret: WebhookFixtures.secret)
        let order = try await razorpay.orders.create(.init(amount: .inr(rupees: 500), receipt: "rcpt_42"))
        let checkoutResponse = CheckoutResponse(paymentID: "pay_TEST000001", orderID: order.id, signature: WebhookFixtures.paymentSignature)
        try razorpay.verify(checkoutResponse)
        let payment = try await razorpay.payments.capture(checkoutResponse.paymentID, amount: order.amount)
        var statuses: [Refund.Status] = []
        for try await refund in razorpay.payments.refunds(of: payment.id) { statuses.append(refund.status) }
        #expect(statuses == [.processed])
        let event = try razorpay.webhooks.verify(WebhookFixtures.captured.body, signature: WebhookFixtures.captured.signature)
        guard case .paymentCaptured(let captured) = event else { Issue.record("got \(event)"); return }
        #expect(captured.id == payment.id)
    }

    @Test func errorHandlingSnippet() async {
        let mock = MockTransport(status: .badRequest, json: #"{"error":{"code":"BAD_REQUEST_ERROR","description":"bad","field":"amount"}}"#)
        let razorpay = RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
        var handled = ""
        do {
            _ = try await razorpay.payments.capture("pay_TEST000001", amount: .inr(paise: 1))
        } catch where error.isInvalidAmount {
            handled = "amount"
        } catch {
            handled = "other"
        }
        #expect(handled == "amount")
    }
}
