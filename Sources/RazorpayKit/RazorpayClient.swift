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
    
    public init(httpClient: HTTPClient, key: String, secret: String, environment: Environment) {
        self.handler = RazorpayAPIHandler(httpClient: httpClient, key: key, secret: secret, environment: environment)
        account = RazorpayAccountRoutes(client: handler, baseUrl: environment.baseUrl)
        addon = RazorpayAddonRoutes(client: handler, baseUrl: environment.baseUrl)
        card = RazorpayCardRoutes(client: handler, baseUrl: environment.baseUrl)
        customer = RazorpayCustomerRoutes(client: handler, baseUrl: environment.baseUrl)
        fundAccount = RazorpayFundAccountRoutes(client: handler, baseUrl: environment.baseUrl)
        iin = RazorpayIINRoutes(client: handler, baseUrl: environment.baseUrl)
        invoice = RazorpayInvoiceRoutes(client: handler, baseUrl: environment.baseUrl)
        item = RazorpayItemRoutes(client: handler, baseUrl: environment.baseUrl)
        order = RazorpayOrderRoutes(client: handler, baseUrl: environment.baseUrl)
        payment = RazorpayPaymentRoutes(client: handler, baseUrl: environment.baseUrl)
        paymentLink = RazorpayPaymentLinkRoutes(client: handler, baseUrl: environment.baseUrl)
        product = RazorpayProductRoutes(client: handler, baseUrl: environment.baseUrl)
        qrCode = RazorpayQRCodeRoutes(client: handler, baseUrl: environment.baseUrl)
        refund = RazorpayRefundRoutes(client: handler, baseUrl: environment.baseUrl)
        settlement = RazorpaySettlementRoutes(client: handler, baseUrl: environment.baseUrl)
        stakeholder = RazorpayStakeholderRoutes(client: handler, baseUrl: environment.baseUrl)
        subscription = RazorpaySubscriptionRoutes(client: handler, baseUrl: environment.baseUrl)
        token = RazorpayTokenRoutes(client: handler, baseUrl: environment.baseUrl)
        transfer = RazorpayTransferRoutes(client: handler, baseUrl: environment.baseUrl)
        virtualAccount = RazorpayVirtualAccountRoutes(client: handler, baseUrl: environment.baseUrl)
        webhook = RazorpayWebhookRoutes(client: handler, baseUrl: environment.baseUrl)
    }
}
