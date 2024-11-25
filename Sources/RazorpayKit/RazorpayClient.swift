import NIO
import AsyncHTTPClient

/// A client for interacting with the Razorpay API.
///
/// The `RazorpayClient` provides access to all Razorpay API endpoints through dedicated route handlers.
/// Initialize it with your API credentials to start making API requests.
///
/// ```swift
/// let httpClient = HTTPClient(eventLoopGroupProvider: .shared)
/// let razorpay = RazorpayClient(httpClient: httpClient,
///                              key: "your_key",
///                              secret: "your_secret")
/// ```
///
/// ## Topics
///
/// ### Account Management
/// - ``account``
/// - ``stakeholder``
///
/// ### Payment Processing
/// - ``payment``
/// - ``paymentLink``
/// - ``order``
/// - ``refund``
///
/// ### Customer Management
/// - ``customer``
/// - ``card``
/// - ``token``
///
/// ### Banking & Transfers
/// - ``fundAccount``
/// - ``transfer``
/// - ``virtualAccount``
/// - ``settlement``
///
/// ### Products & Subscriptions
/// - ``product``
/// - ``subscription``
/// - ``invoice``
/// - ``item``
///
/// ### Additional Features
/// - ``addon``
/// - ``iin``
/// - ``qrCode``
/// - ``webhook``
public final class RazorpayClient {
    
    /// Routes for managing Razorpay accounts
    public var account: RazorpayAccountRoutes
    
    /// Routes for managing addons
    public var addon: RazorpayAddonRoutes
    
    /// Routes for managing cards
    public var card: RazorpayCardRoutes
    
    /// Routes for managing customers
    public var customer: RazorpayCustomerRoutes
    
    /// Routes for managing fund accounts
    public var fundAccount: RazorpayFundAccountRoutes
    
    /// Routes for managing IIN (Issuer Identification Numbers)
    public var iin: RazorpayIINRoutes
    
    /// Routes for managing invoices
    public var invoice: RazorpayInvoiceRoutes
    
    /// Routes for managing items
    public var item: RazorpayItemRoutes
    
    /// Routes for managing orders
    public var order: RazorpayOrderRoutes
    
    /// Routes for managing payments
    public var payment: RazorpayPaymentRoutes
    
    /// Routes for managing payment links
    public var paymentLink: RazorpayPaymentLinkRoutes
    
    /// Routes for managing products
    public var product: RazorpayProductRoutes
    
    /// Routes for managing QR codes
    public var qrCode: RazorpayQRCodeRoutes
    
    /// Routes for managing refunds
    public var refund: RazorpayRefundRoutes
    
    /// Routes for managing settlements
    public var settlement: RazorpaySettlementRoutes
    
    /// Routes for managing stakeholders
    public var stakeholder: RazorpayStakeholderRoutes
    
    /// Routes for managing subscriptions
    public var subscription: RazorpaySubscriptionRoutes
    
    /// Routes for managing tokens
    public var token: RazorpayTokenRoutes
    
    /// Routes for managing transfers
    public var transfer: RazorpayTransferRoutes
    
    /// Routes for managing virtual accounts
    public var virtualAccount: RazorpayVirtualAccountRoutes
    
    /// Routes for managing webhooks
    public var webhook: RazorpayWebhookRoutes

    var handler: RazorpayAPIHandler
    
    /// Creates a new Razorpay API client.
    /// - Parameters:
    ///   - httpClient: The HTTP client to use for making requests
    ///   - key: Your Razorpay API key
    ///   - secret: Your Razorpay API secret
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
