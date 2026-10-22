import RazorpayCore

extension RazorpayClient {
    /// QR codes: create, fetch, list, payments, close. See https://razorpay.com/docs/api/qr-codes/.
    public var qrCodes: QRCodes { QRCodes(handler: handler) }

    /// QR codes: create, fetch, list, payments, close.
    public struct QRCodes: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
