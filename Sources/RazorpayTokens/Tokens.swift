import RazorpayCore

extension RazorpayClient {
    /// Saved customer tokens: list, fetch, delete. See https://razorpay.com/docs/api/payments/tokens/.
    public var tokens: Tokens { Tokens(handler: handler) }

    /// Saved customer tokens: list, fetch, delete.
    public struct Tokens: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
