import RazorpayCore

/// The untyped `[String: Any]` routes from 0.x. Prefer the typed modules, for example
/// `razorpay.payments` from RazorpayPayments.
extension RazorpayClient {
    public var account: RazorpayAccountRoutes { RazorpayAccountRoutes(client: handler) }
    public var addon: RazorpayAddonRoutes { RazorpayAddonRoutes(client: handler) }
    public var card: RazorpayCardRoutes { RazorpayCardRoutes(client: handler) }
    public var customer: RazorpayCustomerRoutes { RazorpayCustomerRoutes(client: handler) }
    public var fundAccount: RazorpayFundAccountRoutes { RazorpayFundAccountRoutes(client: handler) }
    public var iin: RazorpayIINRoutes { RazorpayIINRoutes(client: handler) }
    public var invoice: RazorpayInvoiceRoutes { RazorpayInvoiceRoutes(client: handler) }
    public var item: RazorpayItemRoutes { RazorpayItemRoutes(client: handler) }
    public var order: RazorpayOrderRoutes { RazorpayOrderRoutes(client: handler) }
    public var payment: RazorpayPaymentRoutes { RazorpayPaymentRoutes(client: handler) }
    public var paymentLink: RazorpayPaymentLinkRoutes { RazorpayPaymentLinkRoutes(client: handler) }
    public var product: RazorpayProductRoutes { RazorpayProductRoutes(client: handler) }
    public var qrCode: RazorpayQRCodeRoutes { RazorpayQRCodeRoutes(client: handler) }
    public var refund: RazorpayRefundRoutes { RazorpayRefundRoutes(client: handler) }
    public var settlement: RazorpaySettlementRoutes { RazorpaySettlementRoutes(client: handler) }
    public var stakeholder: RazorpayStakeholderRoutes { RazorpayStakeholderRoutes(client: handler) }
    public var subscription: RazorpaySubscriptionRoutes { RazorpaySubscriptionRoutes(client: handler) }
    public var token: RazorpayTokenRoutes { RazorpayTokenRoutes(client: handler) }
    public var transfer: RazorpayTransferRoutes { RazorpayTransferRoutes(client: handler) }
    public var virtualAccount: RazorpayVirtualAccountRoutes { RazorpayVirtualAccountRoutes(client: handler) }
    public var webhook: RazorpayWebhookRoutes { RazorpayWebhookRoutes(client: handler) }
}
