import RazorpayCore

/// The untyped `[String: Any]` routes from 0.x. Prefer the typed modules, for example
/// `razorpay.payments` from RazorpayPayments.
extension RazorpayClient {
    public var account: RazorpayAccountRoutes { RazorpayAccountRoutes(client: handler) }
    public var addon: RazorpayAddonRoutes { RazorpayAddonRoutes(client: handler) }
    @available(*, deprecated, renamed: "cards", message: "Use the typed `cards` API; `raw` covers anything it doesn't.")
    public var card: RazorpayCardRoutes { RazorpayCardRoutes(client: handler) }
    @available(*, deprecated, renamed: "customers", message: "Use the typed `customers` API; `raw` covers anything it doesn't.")
    public var customer: RazorpayCustomerRoutes { RazorpayCustomerRoutes(client: handler) }
    @available(*, deprecated, renamed: "fundAccounts", message: "Use the typed `fundAccounts` API; `raw` covers anything it doesn't.")
    public var fundAccount: RazorpayFundAccountRoutes { RazorpayFundAccountRoutes(client: handler) }
    public var iin: RazorpayIINRoutes { RazorpayIINRoutes(client: handler) }
    public var invoice: RazorpayInvoiceRoutes { RazorpayInvoiceRoutes(client: handler) }
    public var item: RazorpayItemRoutes { RazorpayItemRoutes(client: handler) }
    @available(*, deprecated, renamed: "orders", message: "Use the typed `orders` API; `raw` covers anything it doesn't.")
    public var order: RazorpayOrderRoutes { RazorpayOrderRoutes(client: handler) }
    @available(*, deprecated, renamed: "payments", message: "Use the typed `payments` API; `raw` covers anything it doesn't.")
    public var payment: RazorpayPaymentRoutes { RazorpayPaymentRoutes(client: handler) }
    @available(*, deprecated, renamed: "paymentLinks", message: "Use the typed `paymentLinks` API; `raw` covers anything it doesn't.")
    public var paymentLink: RazorpayPaymentLinkRoutes { RazorpayPaymentLinkRoutes(client: handler) }
    public var product: RazorpayProductRoutes { RazorpayProductRoutes(client: handler) }
    @available(*, deprecated, renamed: "qrCodes", message: "Use the typed `qrCodes` API; `raw` covers anything it doesn't.")
    public var qrCode: RazorpayQRCodeRoutes { RazorpayQRCodeRoutes(client: handler) }
    @available(*, deprecated, renamed: "refunds", message: "Use the typed `refunds` API; `raw` covers anything it doesn't.")
    public var refund: RazorpayRefundRoutes { RazorpayRefundRoutes(client: handler) }
    public var settlement: RazorpaySettlementRoutes { RazorpaySettlementRoutes(client: handler) }
    @available(*, deprecated, renamed: "linkedAccounts", message: "Use the typed `linkedAccounts` API; `raw` covers anything it doesn't.")
    public var stakeholder: RazorpayStakeholderRoutes { RazorpayStakeholderRoutes(client: handler) }
    public var subscription: RazorpaySubscriptionRoutes { RazorpaySubscriptionRoutes(client: handler) }
    @available(*, deprecated, renamed: "tokens", message: "Use the typed `tokens` API; `raw` covers anything it doesn't.")
    public var token: RazorpayTokenRoutes { RazorpayTokenRoutes(client: handler) }
    @available(*, deprecated, renamed: "transfers", message: "Use the typed `transfers` API; `raw` covers anything it doesn't.")
    public var transfer: RazorpayTransferRoutes { RazorpayTransferRoutes(client: handler) }
    @available(*, deprecated, renamed: "virtualAccounts", message: "Use the typed `virtualAccounts` API; `raw` covers anything it doesn't.")
    public var virtualAccount: RazorpayVirtualAccountRoutes { RazorpayVirtualAccountRoutes(client: handler) }
    public var webhook: RazorpayWebhookRoutes { RazorpayWebhookRoutes(client: handler) }
}
