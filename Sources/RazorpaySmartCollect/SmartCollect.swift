import RazorpayCore

extension RazorpayClient {
    /// Smart Collect virtual accounts. See https://razorpay.com/docs/api/payments/smart-collect/.
    public var virtualAccounts: VirtualAccounts { VirtualAccounts(handler: handler) }
    /// Customer fund accounts. See https://razorpay.com/docs/api/payments/fund-accounts/.
    public var fundAccounts: FundAccounts { FundAccounts(handler: handler) }

    /// Smart Collect virtual accounts.
    public struct VirtualAccounts: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }

    /// Customer fund accounts.
    public struct FundAccounts: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
