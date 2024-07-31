import NIO
import AsyncHTTPClient

public final class RazorpayClient {
    
    public var account: RazorpayAccountRoutes
    public var addon: RazorpayAddonRoutes
    public var card: RazorpayCardRoutes
    public var customer: RazorpayCustomerRoutes
    public var fundAccount: RazorpayFundAccountRoutes
    public var iin: RazorpayIINRoutes
    public var invoice: RazorpayInvoiceRoutes
    public var item: RazorpayItemRoutes
    public var order: RazorpayOrderRoutes
    public var payment: RazorpayPaymentRoutes
    public var paymentLink: RazorpayPaymentLinkRoutes
    public var product: RazorpayProductRoutes
    public var qrCode: RazorpayQRCodeRoutes
    public var refund: RazorpayRefundRoutes
    public var settlement: RazorpaySettlementRoutes
    public var stakeholder: RazorpayStakeholderRoutes
    public var subscription: RazorpaySubscriptionRoutes
    public var token: RazorpayTokenRoutes
    public var transfer: RazorpayTransferRoutes
    public var virtualAccount: RazorpayVirtualAccountRoutes
    public var webhook: RazorpayWebhookRoutes

    var handler: RazorpayAPIHandler
    
    public init(httpClient: HTTPClient, key: String, secret: String) {
        self.handler = RazorpayAPIHandler(httpClient: httpClient, key: key, secret: secret)
        account = RazorpayAccountRoutes(client: handler)
        addon = RazorpayAddonRoutes(client: handler)
        card = RazorpayCardRoutes(client: handler)
        customer = RazorpayCustomerRoutes(client: handler)
        fundAccount = RazorpayFundAccountRoutes(client: handler)
        iin = RazorpayIINRoutes(client: handler)
        invoice = RazorpayInvoiceRoutes(client: handler)
        item = RazorpayItemRoutes(client: handler)
        order = RazorpayOrderRoutes(client: handler)
        payment = RazorpayPaymentRoutes(client: handler)
        paymentLink = RazorpayPaymentLinkRoutes(client: handler)
        product = RazorpayProductRoutes(client: handler)
        qrCode = RazorpayQRCodeRoutes(client: handler)
        refund = RazorpayRefundRoutes(client: handler)
        settlement = RazorpaySettlementRoutes(client: handler)
        stakeholder = RazorpayStakeholderRoutes(client: handler)
        subscription = RazorpaySubscriptionRoutes(client: handler)
        token = RazorpayTokenRoutes(client: handler)
        transfer = RazorpayTransferRoutes(client: handler)
        virtualAccount = RazorpayVirtualAccountRoutes(client: handler)
        webhook = RazorpayWebhookRoutes(client: handler)
    }
}
