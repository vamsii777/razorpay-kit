import Foundation
import Testing
@testable import RazorpayKit

// Fixtures are deliberately fake, low-entropy placeholders. Signatures were produced with
// `printf %s "$payload" | openssl dgst -sha256 -hmac "$secret"`.
@Suite("RazorpaySignature")
struct RazorpaySignatureTests {
    static let webhookBody = #"{"entity":"event","event":"payment.captured","payload":{"payment":{"entity":{"id":"pay_TEST000001","entity":"payment","amount":5000,"currency":"INR","status":"captured"}}},"created_at":1700000000}"#
    static let webhookSecret = "test_webhook_secret"
    static let webhookSignature = "0d275e1c838f21562cc481dfc442396402a9d405e3fda1ad3be1a4e37fa339e4"
    static let keySecret = "test_key_secret"

    @Test func webhookString() {
        #expect(RazorpaySignature.verifyWebhook(body: Self.webhookBody, signature: Self.webhookSignature, secret: Self.webhookSecret))
    }

    @Test func webhookRawBytesCaseAndWhitespaceInsensitive() {
        let raw = Data(Self.webhookBody.utf8)
        #expect(RazorpaySignature.verifyWebhook(body: raw, signature: Self.webhookSignature.uppercased(), secret: Self.webhookSecret))
        #expect(RazorpaySignature.verifyWebhook(body: raw, signature: " \(Self.webhookSignature)\r\n", secret: Self.webhookSecret))
    }

    @Test func tamperedBodyFails() {
        #expect(!RazorpaySignature.verifyWebhook(body: Self.webhookBody.replacingOccurrences(of: "5000", with: "5001"), signature: Self.webhookSignature, secret: Self.webhookSecret))
        #expect(!RazorpaySignature.verifyWebhook(body: Self.webhookBody + " ", signature: Self.webhookSignature, secret: Self.webhookSecret))
    }

    @Test func nonUTF8BodyFailsWithoutCrashing() {
        let bytes: [UInt8] = [0xFF, 0xFE, 0x00, 0xC3]
        #expect(!RazorpaySignature.verifyWebhook(body: bytes, signature: Self.webhookSignature, secret: Self.webhookSecret))
    }

    @Test func wrongOrEmptySecretFails() {
        #expect(!RazorpaySignature.verifyWebhook(body: Self.webhookBody, signature: Self.webhookSignature, secret: "other"))
        #expect(!RazorpaySignature.verifyWebhook(body: Self.webhookBody, signature: Self.webhookSignature, secret: ""))
    }

    @Test(arguments: [
        "",
        "0d275e1c838f21562cc481dfc442396402a9d405e3fda1ad3be1a4e37fa33900",
        "not_hex_at_all",
        "0d275e1c838f21562cc481dfc442396402a9d405e3fda1ad3be1a4e37fa339eZ",
        "0d275e1c838f21562cc481dfc442396402a9d405e3fda1ad3be1a4e37fa339e",
        "0d275e1c838f21562cc481dfc442396402a9d405e3fda1ad3be1a4e37fa339e400",
    ])
    func malformedSignaturesFail(signature: String) {
        #expect(!RazorpaySignature.verifyWebhook(body: Self.webhookBody, signature: signature, secret: Self.webhookSecret))
    }

    @Test func payment() {
        #expect(RazorpaySignature.verifyPayment(orderID: "order_TEST000001", paymentID: "pay_TEST000001", signature: "b1cc078a35dec6e3a22bcbb547fa80b5dc63c92802705313920347e24a039e65", secret: Self.keySecret))
        #expect(!RazorpaySignature.verifyPayment(orderID: "order_TEST000002", paymentID: "pay_TEST000001", signature: "b1cc078a35dec6e3a22bcbb547fa80b5dc63c92802705313920347e24a039e65", secret: Self.keySecret))
    }

    @Test func subscription() {
        #expect(RazorpaySignature.verifySubscription(paymentID: "pay_TEST000001", subscriptionID: "sub_TEST000001", signature: "d9d2467c333c1a6bb7ee61eb647ea01b0220efab691bb3108618c5f5d218ecec", secret: Self.keySecret))
    }

    @Test func paymentLink() {
        #expect(RazorpaySignature.verifyPaymentLink(paymentLinkID: "plink_TEST000001", referenceID: "ref_001", status: "paid", paymentID: "pay_TEST000001", signature: "b5d780a1028cd54fda0fd7ba6ac0723bfae945216b10bb651cd909be1732be6e", secret: Self.keySecret))
    }
}
