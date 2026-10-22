import RazorpayCore

extension RazorpayClient {
    /// Payment Links: create, fetch, list, update, cancel, notify. See https://razorpay.com/docs/api/payments/payment-links/.
    public var paymentLinks: PaymentLinks { PaymentLinks(handler: handler) }

    /// Payment Links: create, fetch, list, update, cancel, notify.
    public struct PaymentLinks: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
