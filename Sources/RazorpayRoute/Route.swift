import RazorpayCore

extension RazorpayClient {
    /// Route transfers and reversals. See https://razorpay.com/docs/api/payments/route/.
    public var transfers: Transfers { Transfers(handler: handler) }
    /// Route linked accounts and their stakeholders.
    public var linkedAccounts: LinkedAccounts { LinkedAccounts(handler: handler) }

    /// Route transfers and reversals.
    public struct Transfers: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }

    /// Route linked accounts and their stakeholders.
    public struct LinkedAccounts: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
