import Crypto
import Foundation

/// Verifies Razorpay HMAC-SHA256 signatures in constant time.
///
/// All checks compute `HMAC-SHA256(secret, payload)` with swift-crypto and compare it to the
/// hex-encoded signature using `HMAC.isValidAuthenticationCode`, which is constant time.
/// Malformed hex or a wrong-length signature returns `false`; nothing throws.
///
/// Payloads follow the official SDKs (e.g. razorpay-go):
/// - Webhook: the raw request body bytes, signed with the webhook secret
///   (`X-Razorpay-Signature`). See https://razorpay.com/docs/webhooks/validate-test/
/// - Payment: `order_id|payment_id`, signed with the key secret.
///   See https://razorpay.com/docs/payments/payment-gateway/web-integration/standard/build-integration/#verify-payment-signature
/// - Subscription: `payment_id|subscription_id`, signed with the key secret.
///   See https://razorpay.com/docs/payments/subscriptions/integration-guide/#payment-verification
/// - Payment link: `plink_id|reference_id|status|payment_id`, signed with the key secret.
///   See https://razorpay.com/docs/payments/payment-links/apis/#verify-signature
public enum RazorpaySignature {

    /// Verifies a webhook signature against the **raw** request body bytes.
    ///
    /// Do not re-encode the JSON before verifying; use the exact bytes received.
    /// See https://razorpay.com/docs/webhooks/validate-test/
    /// - Parameters:
    ///   - body: Raw request body bytes.
    ///   - signature: Value of the `X-Razorpay-Signature` header (hex).
    ///   - secret: The webhook secret configured in the Dashboard.
    /// - Returns: `true` only if the signature is valid.
    public static func verifyWebhook<Body: DataProtocol>(body: Body, signature: String, secret: String) -> Bool {
        verify(payload: body, signature: signature, secret: secret)
    }

    /// Verifies a webhook signature against a raw body string (its UTF-8 bytes).
    ///
    /// See https://razorpay.com/docs/webhooks/validate-test/
    public static func verifyWebhook(body: String, signature: String, secret: String) -> Bool {
        verify(payload: Array(body.utf8), signature: signature, secret: secret)
    }

    /// Verifies a Checkout payment signature (`order_id|payment_id`).
    ///
    /// See https://razorpay.com/docs/payments/payment-gateway/web-integration/standard/build-integration/#verify-payment-signature
    /// - Parameters:
    ///   - orderID: `razorpay_order_id`.
    ///   - paymentID: `razorpay_payment_id`.
    ///   - signature: `razorpay_signature` (hex).
    ///   - secret: Your API key secret.
    public static func verifyPayment(orderID: String, paymentID: String, signature: String, secret: String) -> Bool {
        verify(payload: Array("\(orderID)|\(paymentID)".utf8), signature: signature, secret: secret)
    }

    /// Verifies a subscription payment signature (`payment_id|subscription_id`).
    ///
    /// See https://razorpay.com/docs/payments/subscriptions/integration-guide/#payment-verification
    public static func verifySubscription(paymentID: String, subscriptionID: String, signature: String, secret: String) -> Bool {
        verify(payload: Array("\(paymentID)|\(subscriptionID)".utf8), signature: signature, secret: secret)
    }

    /// Verifies a payment link callback signature (`plink_id|reference_id|status|payment_id`).
    ///
    /// See https://razorpay.com/docs/payments/payment-links/apis/#verify-signature
    public static func verifyPaymentLink(
        paymentLinkID: String,
        referenceID: String,
        status: String,
        paymentID: String,
        signature: String,
        secret: String
    ) -> Bool {
        let payload = "\(paymentLinkID)|\(referenceID)|\(status)|\(paymentID)"
        return verify(payload: Array(payload.utf8), signature: signature, secret: secret)
    }

    /// Verifies a hex-encoded HMAC-SHA256 `signature` over arbitrary `payload` bytes in constant time.
    ///
    /// See https://razorpay.com/docs/webhooks/validate-test/
    public static func verify<Payload: DataProtocol>(payload: Payload, signature: String, secret: String) -> Bool {
        let key = SymmetricKey(data: Array(secret.utf8))
        // Decode fully even when malformed so we don't exit early on the first bad byte.
        let (bytes, valid) = decodeHex(signature)
        let ok = HMAC<SHA256>.isValidAuthenticationCode(bytes, authenticating: payload, using: key)
        return ok && valid
    }

    /// Decodes hex without early exit. Returns the bytes and whether the input was well-formed.
    static func decodeHex(_ string: String) -> (bytes: [UInt8], valid: Bool) {
        let chars = Array(string.utf8)
        var valid = chars.count % 2 == 0
        var out = [UInt8]()
        out.reserveCapacity(chars.count / 2)
        var i = 0
        while i + 1 < chars.count {
            let (hi, hv) = nibble(chars[i])
            let (lo, lv) = nibble(chars[i + 1])
            valid = valid && hv && lv
            out.append(hi << 4 | lo)
            i += 2
        }
        return (out, valid)
    }

    private static func nibble(_ c: UInt8) -> (UInt8, Bool) {
        switch c {
        case UInt8(ascii: "0")...UInt8(ascii: "9"): return (c &- UInt8(ascii: "0"), true)
        case UInt8(ascii: "a")...UInt8(ascii: "f"): return (c &- UInt8(ascii: "a") &+ 10, true)
        case UInt8(ascii: "A")...UInt8(ascii: "F"): return (c &- UInt8(ascii: "A") &+ 10, true)
        default: return (0, false)
        }
    }
}
