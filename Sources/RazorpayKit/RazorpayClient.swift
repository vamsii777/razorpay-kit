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
public struct RazorpayClient: Sendable {
    
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
    /// Secrets used only for local signature checks. Never exposed via description or mirror.
    let signing: SigningSecrets
    
    /// Creates a new Razorpay API client.
    /// - Parameters:
    ///   - httpClient: The HTTP client to use for making requests
    ///   - key: Your Razorpay API key
    ///   - secret: Your Razorpay API secret
    ///   - webhookSecret: The secret set on your webhook in the Dashboard. Needed for
    ///     `webhooks.verify(_:signature:)`.
    public init(_ httpClient: HTTPClient = HTTPClient.shared, key: String, secret: String, webhookSecret: String? = nil) {
        self.init(transport: AsyncHTTPClientTransport(httpClient: httpClient), key: key, secret: secret, webhookSecret: webhookSecret)
    }

    /// Creates a client that sends every request through a custom transport.
    ///
    /// The base URL is always `https://api.razorpay.com`. A transport can change how requests are
    /// sent, for example a mock in tests, but it cannot change the host.
    /// - Parameters:
    ///   - transport: The transport that sends requests.
    ///   - key: Your Razorpay API key ID.
    ///   - secret: Your Razorpay API key secret.
    ///   - webhookSecret: The webhook secret from the Dashboard, used by ``webhooks``.
    public init(transport: any RazorpayTransport, key: String, secret: String, webhookSecret: String? = nil) {
        self.handler = RazorpayAPIHandler(transport: transport, key: key, secret: secret)
        self.signing = SigningSecrets(keySecret: secret, webhookSecret: webhookSecret)
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

extension RazorpayClient: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// A description that never includes the API key or secret.
    public var description: String { "RazorpayClient(credentials: <redacted>)" }
    /// A debug description that never includes the API key or secret.
    public var debugDescription: String { description }
    /// A mirror that hides the API key, secret and Authorization header.
    public var customMirror: Mirror {
        Mirror(self, children: ["credentials": "<redacted>"], displayStyle: .struct)
    }
}

/// Holds signing secrets and hides them from `print`, `dump` and string interpolation.
struct SigningSecrets: Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    let keySecret: String
    let webhookSecret: String?
    var description: String { "SigningSecrets(<redacted>)" }
    var debugDescription: String { description }
    var customMirror: Mirror { Mirror(self, children: [], displayStyle: .struct) }
}
