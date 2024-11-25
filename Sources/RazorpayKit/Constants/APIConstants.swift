/// Constants defining the API endpoints and URLs used by the Razorpay API
///
/// This struct contains static constants for all the API endpoints used to interact with
/// Razorpay's REST API. The constants include the base URL and paths for various resources
/// like orders, payments, customers etc.
public struct APIConstants {
    /// The base URL for all Razorpay API requests
    static let baseURL = "https://api.razorpay.com"
    
    /// API version 1 path component
    static let v1 = "/v1"
    
    /// API version 2 path component
    static let v2 = "/v2"
    
    /// Path for orders related endpoints
    static let orderURL = "/orders"
    
    /// Path for invoice related endpoints
    static let invoiceURL = "/invoices"
    
    /// Path for payment related endpoints
    static let paymentURL = "/payments"
    
    /// Path for payment links related endpoints
    static let paymentLinkURL = "/payment_links"
    
    /// Path for refund related endpoints
    static let refundURL = "/refunds"
    
    /// Path for card related endpoints
    static let cardURL = "/cards"
    
    /// Path for customer related endpoints
    static let customerURL = "/customers"
    
    /// Path for addon related endpoints
    static let addonURL = "/addons"
    
    /// Path for transfer related endpoints
    static let transferURL = "/transfers"
    
    /// Path for virtual account related endpoints
    static let virtualAccountURL = "/virtual_accounts"
    
    /// Path for subscription related endpoints
    static let subscriptionURL = "/subscriptions"
    
    /// Path for plan related endpoints
    static let planURL = "/plans"
    
    /// Path for QR code payment related endpoints
    static let qrCodeURL = "/payments/qr_codes"
    
    /// Path for fund account related endpoints
    static let fundAccountURL = "/fund_accounts"
    
    /// Path for settlement related endpoints
    static let settlementURL = "/settlements"
    
    /// Path for item related endpoints
    static let itemURL = "/items"
    
    /// Path for payment methods related endpoints
    static let methodsURL = "/methods"
    
    /// Path for account related endpoints
    static let accountURL = "/accounts"
    
    /// Path for stakeholder related endpoints
    static let stakeholderURL = "/stakeholders"
    
    /// Path for product related endpoints
    static let productURL = "/products"
    
    /// Path for terms and conditions related endpoints
    static let tncURL = "/tnc"
    
    /// Path for IIN (Issuer Identification Number) related endpoints
    static let iinURL = "/iins"
    
    /// Path for webhook related endpoints
    static let webhookURL = "/webhooks"
    
    /// Alternative path for IIN related endpoints
    static let iin: String = "/iins"
    
    /// Alternative path for terms and conditions
    static let tnc: String = "/tnc"
    
    /// Alternative path for webhooks
    static let webhook: String = "/webhooks"
}
