import Foundation
import Testing
@testable import RazorpayKit

// Vectors from razorpay-go resources/verify_payment_test.go (fake test secrets, not real keys).
@Suite("RazorpaySignature")
struct RazorpaySignatureTests {
    static let webhookBody = ##"{"entity":"event","account_id":"acc_HVFD0PFnHPAzKj","event":"payment.authorized","contains":["payment"],"payload":{"payment":{"entity":{"id":"pay_JUEM4c0pSLpFEW","entity":"payment","amount":12300,"currency":"INR","status":"authorized","order_id":"order_JUELuT6cFaHkvd","invoice_id":null,"international":false,"method":"netbanking","amount_refunded":0,"refund_status":null,"captured":false,"description":"#JUELZ1z1EC0pwi","card_id":null,"bank":"SBIN","wallet":null,"vpa":null,"email":"prathmesh.bijjargi@razorpay.com","contact":"+917411714931","notes":[],"fee":null,"tax":null,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"bank_transaction_id":"6416615"},"created_at":1652339804}}},"created_at":1652339806}"##
    static let webhookSignature = "ea962f3a2a8090aa14ef10fc178306edcb46ee7ccadae8afe2275cda26f3d2a6"
    static let webhookSecret = "123456"
    static let keySecret = "EnLs21M47BllR3X8PSFtjtbd"

    @Test func webhookKnownGoodString() {
        #expect(RazorpaySignature.verifyWebhook(body: Self.webhookBody, signature: Self.webhookSignature, secret: Self.webhookSecret))
    }

    @Test func webhookKnownGoodRawBytes() {
        let raw = Data(Self.webhookBody.utf8)
        #expect(RazorpaySignature.verifyWebhook(body: raw, signature: Self.webhookSignature, secret: Self.webhookSecret))
        #expect(RazorpaySignature.verifyWebhook(body: raw, signature: Self.webhookSignature.uppercased(), secret: Self.webhookSecret))
    }

    @Test func webhookTamperedBodyFails() {
        let tampered = Self.webhookBody.replacingOccurrences(of: "12300", with: "12301")
        #expect(!RazorpaySignature.verifyWebhook(body: tampered, signature: Self.webhookSignature, secret: Self.webhookSecret))
        // Re-encoding (whitespace change) must fail: verify raw bytes only.
        #expect(!RazorpaySignature.verifyWebhook(body: Self.webhookBody + " ", signature: Self.webhookSignature, secret: Self.webhookSecret))
    }

    @Test func webhookWrongSecretFails() {
        #expect(!RazorpaySignature.verifyWebhook(body: Self.webhookBody, signature: Self.webhookSignature, secret: "654321"))
        #expect(!RazorpaySignature.verifyWebhook(body: Self.webhookBody, signature: Self.webhookSignature, secret: ""))
    }

    @Test(arguments: [
        "ea962f3a2a8090aa14ef10fc178306edcb46ee7ccadae8afe2275cda26f3d200", // tampered
        "aabbccddeeff00112233445566778899aabbccddeeff00112233445566778899", // valid hex, wrong value
        "completely_wrong_signature_that_is_not_valid",                     // not hex
        "ea962f3a2a8090aa14ef10fc178306edcb46ee7ccadae8afe2275cda26f3d2aZ", // one bad char
        "ea962f3a2a8090aa14ef10fc178306edcb46ee7ccadae8afe2275cda26f3d2a",  // odd length
        "ea962f3a2a8090aa14ef10fc178306edcb46ee7ccadae8afe2275cda26f3d2",   // short
        "ea962f3a2a8090aa14ef10fc178306edcb46ee7ccadae8afe2275cda26f3d2a600", // long
        "",
    ])
    func webhookBadSignatureFails(signature: String) {
        #expect(!RazorpaySignature.verifyWebhook(body: Self.webhookBody, signature: signature, secret: Self.webhookSecret))
    }

    @Test func paymentKnownGood() {
        let sig = "0d4e745a1838664ad6c9c9902212a32d627d68e917290b0ad5f08ff4561bc50f"
        #expect(RazorpaySignature.verifyPayment(orderID: "order_IEIaMR65cu6nz3", paymentID: "pay_IH4NVgf4Dreq1l", signature: sig, secret: Self.keySecret))
        // Order matters: order_id|payment_id.
        #expect(!RazorpaySignature.verifyPayment(orderID: "pay_IH4NVgf4Dreq1l", paymentID: "order_IEIaMR65cu6nz3", signature: sig, secret: Self.keySecret))
        #expect(!RazorpaySignature.verifyPayment(orderID: "order_IEIaMR65cu6nz3", paymentID: "pay_IH4NVgf4Dreq1l", signature: sig, secret: "wrong"))
        #expect(!RazorpaySignature.verifyPayment(orderID: "order_test123", paymentID: "pay_test456", signature: "invalid_signature_here", secret: "test_secret"))
    }

    @Test func subscriptionKnownGood() {
        let sig = "601f383334975c714c91a7d97dd723eb56520318355863dcf3821c0d07a17693"
        #expect(RazorpaySignature.verifySubscription(paymentID: "pay_IDZNwZZFtnjyym", subscriptionID: "sub_ID6MOhgkcoHj9I", signature: sig, secret: Self.keySecret))
        #expect(!RazorpaySignature.verifySubscription(paymentID: "sub_ID6MOhgkcoHj9I", subscriptionID: "pay_IDZNwZZFtnjyym", signature: sig, secret: Self.keySecret))
        #expect(!RazorpaySignature.verifySubscription(paymentID: "pay_test456", subscriptionID: "sub_test123", signature: "invalid_signature_here", secret: "test_secret"))
    }

    @Test func paymentLinkKnownGood() {
        let sig = "07ae18789e35093e51d0a491eb9922646f3f82773547e5b0f67ee3f2d3bf7d5b"
        #expect(RazorpaySignature.verifyPaymentLink(paymentLinkID: "plink_IH3cNucfVEgV68", referenceID: "TSsd1989", status: "paid", paymentID: "pay_IH3d0ara9bSsjQ", signature: sig, secret: Self.keySecret))
        #expect(!RazorpaySignature.verifyPaymentLink(paymentLinkID: "plink_IH3cNucfVEgV68", referenceID: "TSsd1989", status: "cancelled", paymentID: "pay_IH3d0ara9bSsjQ", signature: sig, secret: Self.keySecret))
        #expect(!RazorpaySignature.verifyPaymentLink(paymentLinkID: "plink_test123", referenceID: "ref_test789", status: "paid", paymentID: "pay_test456", signature: "invalid_signature_here", secret: "test_secret"))
    }

    @Test func hexDecoding() {
        #expect(RazorpaySignature.decodeHex("00ffAb").bytes == [0x00, 0xff, 0xab])
        #expect(RazorpaySignature.decodeHex("00ffAb").valid)
        #expect(!RazorpaySignature.decodeHex("0g").valid)
        #expect(!RazorpaySignature.decodeHex("abc").valid)
    }
}
