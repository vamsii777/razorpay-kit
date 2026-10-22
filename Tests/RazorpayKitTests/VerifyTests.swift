import Foundation
import Testing
@testable import RazorpayKit

private let razorpay = RazorpayClient(transport: MockTransport(), key: TestKeys.key, secret: "test_key_secret", webhookSecret: WebhookFixtures.secret)

@Suite("Webhook verification")
struct WebhookVerifyTests {
    @Test func paymentCapturedIsTyped() throws {
        let f = WebhookFixtures.captured
        let event = try razorpay.webhooks.verify(f.body, signature: f.signature)
        guard case .paymentCaptured(let payment) = event else { Issue.record("got \(event)"); return }
        #expect(payment.amount == .inr(paise: 50_000))
        #expect(event.name == "payment.captured" && event.payment?.id == "pay_TEST000001")
    }

    @Test func rawBytesUppercaseAndPaddedSignature() throws {
        let f = WebhookFixtures.captured
        let event = try razorpay.webhooks.verify(Data(f.body.utf8), signature: " \(f.signature.uppercased())\n")
        #expect(event.name == "payment.captured")
    }

    @Test func orderPaidAndRefundProcessed() throws {
        let paid = try razorpay.webhooks.verify(WebhookFixtures.orderPaid.body, signature: WebhookFixtures.orderPaid.signature)
        guard case .orderPaid(let order, let payment) = paid else { Issue.record("got \(paid)"); return }
        #expect(order.id == "order_TEST000001" && payment.orderID == order.id)
        let refunded = try razorpay.webhooks.verify(WebhookFixtures.refundProcessed.body, signature: WebhookFixtures.refundProcessed.signature)
        guard case .refundProcessed(let refund) = refunded else { Issue.record("got \(refunded)"); return }
        #expect(refund.status == .processed)
    }

    @Test func unknownEventsKeepPayload() throws {
        let f = WebhookFixtures.unknown
        let event = try razorpay.webhooks.verify(f.body, signature: f.signature)
        guard case .unknown(let name, let payload) = event else { Issue.record("got \(event)"); return }
        #expect(name == "subscription.charged")
        #expect(payload["subscription"]?["entity"]?["id"] == "sub_TEST000001")
    }

    @Test func tamperedBodyOrMissingHeaderIsMismatch() {
        let f = WebhookFixtures.captured
        for (body, signature) in [(f.body + " ", f.signature as String?), (f.body, nil), (f.body, ""), (f.body, "zz")] {
            do {
                _ = try razorpay.webhooks.verify(body, signature: signature)
                Issue.record("expected mismatch")
            } catch {
                guard case .signatureMismatch(.webhook) = error else { Issue.record("got \(error)"); continue }
            }
        }
    }

    @Test func validSignatureButBadBodyIsDecodingError() {
        for f in [WebhookFixtures.garbled, WebhookFixtures.missingEntity] {
            do {
                _ = try razorpay.webhooks.verify(f.body, signature: f.signature)
                Issue.record("expected decoding error")
            } catch {
                guard case .decoding = error else { Issue.record("got \(error)"); continue }
            }
        }
    }

    @Test func nonUTF8BodyVerifiesThenFailsDecodingCleanly() {
        #expect(throws: RazorpayError.self) {
            try razorpay.webhooks.verify(WebhookFixtures.nonUTF8, signature: WebhookFixtures.nonUTF8Signature)
        }
        #expect(throws: RazorpayError.self) {
            try razorpay.webhooks.verify(WebhookFixtures.nonUTF8, signature: WebhookFixtures.captured.signature)
        }
    }

    @Test func missingSecretIsInvalidRequestAndOverrideWorks() throws {
        let bare = RazorpayClient(transport: MockTransport(), key: TestKeys.key, secret: TestKeys.secret)
        let f = WebhookFixtures.captured
        do {
            _ = try bare.webhooks.verify(f.body, signature: f.signature)
            Issue.record("expected throw")
        } catch {
            guard case .invalidRequest = error else { Issue.record("got \(error)"); return }
        }
        #expect(try bare.webhooks.verify(f.body, signature: f.signature, secret: WebhookFixtures.secret).name == "payment.captured")
    }

    @Test func secretsAreRedacted() {
        let text = "\(razorpay) \(String(reflecting: razorpay)) \(razorpay.signing)"
        var dumped = ""
        dump(razorpay, to: &dumped)
        #expect(!text.contains("test_key_secret") && !text.contains(WebhookFixtures.secret))
        #expect(!dumped.contains("test_key_secret") && !dumped.contains(WebhookFixtures.secret))
    }
}

@Suite("Checkout verification")
struct CheckoutVerifyTests {
    @Test func orderPaymentFromCheckoutJSON() throws {
        let json = #"{"razorpay_payment_id":"pay_TEST000001","razorpay_order_id":"order_TEST000001","razorpay_signature":"\#(WebhookFixtures.paymentSignature)"}"#
        let response = try JSONDecoder().decode(CheckoutResponse.self, from: Data(json.utf8))
        try razorpay.verify(response)
    }

    @Test func subscriptionAndPaymentLink() throws {
        try razorpay.verify(CheckoutResponse(paymentID: "pay_TEST000001", subscriptionID: "sub_TEST000001", signature: WebhookFixtures.subscriptionSignature))
        try razorpay.verify(PaymentLinkCallback(paymentLinkID: "plink_TEST000001", referenceID: "ref_001", status: "paid", paymentID: "pay_TEST000001", signature: WebhookFixtures.paymentLinkSignature))
    }

    @Test func mismatchesAreTyped() {
        do {
            try razorpay.verify(CheckoutResponse(paymentID: "pay_TEST000002", orderID: "order_TEST000001", signature: WebhookFixtures.paymentSignature))
            Issue.record("expected throw")
        } catch {
            #expect(error.description == "The payment signature does not match")
        }
    }

    @Test func missingOrderAndSubscriptionIsInvalidRequest() {
        do {
            try razorpay.verify(CheckoutResponse(paymentID: "pay_TEST000001", signature: "00"))
            Issue.record("expected throw")
        } catch {
            guard case .invalidRequest = error else { Issue.record("got \(error)"); return }
        }
    }
}
