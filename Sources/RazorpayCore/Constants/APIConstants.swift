/// Constants defining the API endpoints and URLs used by the Razorpay API
///
/// This struct contains static constants for all the API endpoints used to interact with
/// Razorpay's REST API. The constants include the base URL and paths for various resources
/// like orders, payments, customers etc.
public struct APIConstants: Sendable {
    /// The base URL for all Razorpay API requests
    package static let baseURL = "https://api.razorpay.com"
    
    /// API version 1 path component
    package static let v1 = "/v1"
    
    /// API version 2 path component
    package static let v2 = "/v2"
    
    /// Path for orders related endpoints
    package static let orderURL = "/orders"
    
    /// Path for invoice related endpoints
    package static let invoiceURL = "/invoices"
    
    /// Path for payment related endpoints
    package static let paymentURL = "/payments"
    
    /// Path for payment links related endpoints
    package static let paymentLinkURL = "/payment_links"
    
    /// Path for refund related endpoints
    package static let refundURL = "/refunds"
    
    /// Path for card related endpoints
    package static let cardURL = "/cards"
    
    /// Path for customer related endpoints
    package static let customerURL = "/customers"
    
    /// Path for addon related endpoints
    package static let addonURL = "/addons"
    
    /// Path for transfer related endpoints
    package static let transferURL = "/transfers"
    
    /// Path for virtual account related endpoints
    package static let virtualAccountURL = "/virtual_accounts"
    
    /// Path for subscription related endpoints
    package static let subscriptionURL = "/subscriptions"
    
    /// Path for plan related endpoints
    package static let planURL = "/plans"
    
    /// Path for QR code payment related endpoints
    package static let qrCodeURL = "/payments/qr_codes"
    
    /// Path for fund account related endpoints
    package static let fundAccountURL = "/fund_accounts"
    
    /// Path for settlement related endpoints
    package static let settlementURL = "/settlements"
    
    /// Path for item related endpoints
    package static let itemURL = "/items"
    
    /// Path for payment methods related endpoints
    package static let methodsURL = "/methods"
    
    /// Path for account related endpoints
    package static let accountURL = "/accounts"
    
    /// Path for stakeholder related endpoints
    package static let stakeholderURL = "/stakeholders"
    
    /// Path for product related endpoints
    package static let productURL = "/products"
    
    /// Path for terms and conditions related endpoints
    package static let tncURL = "/tnc"
    
    /// Path for IIN (Issuer Identification Number) related endpoints
    package static let iinURL = "/iins"
    
    /// Path for webhook related endpoints
    package static let webhookURL = "/webhooks"
    
    /// Alternative path for IIN related endpoints
    package static let iin: String = "/iins"
    
    /// Alternative path for terms and conditions
    package static let tnc: String = "/tnc"
    
    /// Alternative path for webhooks
    package static let webhook: String = "/webhooks"
}
