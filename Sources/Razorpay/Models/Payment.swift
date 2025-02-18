import Foundation

/// Represents a payment in the Razorpay system
public struct Payment: Codable, Sendable, RazorpayResponse {
    /// Unique identifier of the payment
    public let id: String
    
    /// Type of entity (always "payment")
    public let entity: String
    
    /// Payment amount in smallest currency sub-unit
    public let amount: Int
    
    /// Currency of the payment
    public let currency: String
    
    /// Current status of the payment
    public let status: Status
    
    /// Associated order ID if any
    public let orderId: String?
    
    /// Associated invoice ID if any
    public let invoiceId: String?
    
    /// Whether the payment is international
    public let international: Bool
    
    /// Payment method used
    public let method: Method
    
    /// Amount refunded
    public let amountRefunded: Int
    
    /// Refund status
    public let refundStatus: RefundStatus?
    
    /// Whether payment is captured
    public let captured: Bool
    
    /// Payment description
    public let description: String?
    
    /// Card ID if payment made via card
    public let cardId: String?
    
    /// Bank code for netbanking payments
    public let bank: String?
    
    /// Wallet name if payment made via wallet
    public let wallet: String?
    
    /// VPA (UPI ID) used for payment
    public let vpa: String?
    
    /// Customer email
    public let email: String?
    
    /// Customer contact
    public let contact: String?
    
    /// Customer ID if available
    public let customerId: String?
    
    /// Token ID if tokenized payment
    public let tokenId: String?
    
    /// Notes attached to payment
    public let notes: [String: String]
    
    /// Fee charged by Razorpay
    public let fee: Int
    
    /// Tax amount
    public let tax: Int
    
    /// Error code if payment failed
    public let errorCode: String?
    
    /// Error description if payment failed
    public let errorDescription: String?
    
    /// Error source if payment failed
    public let errorSource: String?
    
    /// Error step if payment failed
    public let errorStep: String?
    
    /// Error reason if payment failed
    public let errorReason: String?
    
    /// Additional data from acquirer
    public let acquirerData: AcquirerData?
    
    /// UPI specific details
    public let upi: UPIDetails?
    
    /// Timestamp when payment was created
    public let createdAt: Date
    
    /// Expanded card details (only when specifically requested)
    public let card: Card?
    
    /// EMI details (only when specifically requested)
    public let emi: EMIDetails?
    
    /// Offers applied to the payment (only when specifically requested)
    public let offers: OffersDetails?
    
    /// Payment status
    public enum Status: String, Codable, Sendable {
        case created
        case authorized
        case captured
        case refunded
        case failed
    }
    
    /// Payment method
    public enum Method: String, Codable, Sendable {
        case card
        case netbanking
        case wallet
        case emi
        case upi
    }
    
    /// Refund status
    public enum RefundStatus: String, Codable, Sendable {
        case partial
        case full
    }
    
    /// UPI payment details
    public struct UPIDetails: Codable, Sendable {
        /// The VPA (Virtual Payment Address) used for payment
        public let vpa: String
        
        /// Type of account used for payment
        public let payerAccountType: PayerAccountType?
        
        /// Type of UPI flow (only present for Turbo UPI Payments)
        public let flow: String?
        
        /// Type of account used for UPI payment
        public enum PayerAccountType: String, Codable, Sendable {
            case bankAccount = "bank_account"
            case creditCard = "credit_card"
            case wallet
        }
        
        private enum CodingKeys: String, CodingKey {
            case vpa
            case payerAccountType = "payer_account_type"
            case flow
        }
    }
    
    /// Acquirer provided data
    public struct AcquirerData: Codable, Sendable {
        public let bankTransactionId: String?
        public let authCode: String?
        public let arn: String?
        public let rrn: String?
        
        private enum CodingKeys: String, CodingKey {
            case bankTransactionId = "bank_transaction_id"
            case authCode = "auth_code"
            case arn
            case rrn
        }
    }
    
    /// Detailed card information
    public struct Card: Codable, Sendable {
        /// Unique identifier of the card
        public let id: String
        
        /// Type of entity (always "card")
        public let entity: String
        
        /// Name of the cardholder (may be nil for domestic cards)
        public let name: String?
        
        /// Last 4 digits of the card number
        public let last4: String
        
        /// Card network (e.g., Visa, MasterCard)
        public let network: Network
        
        /// Type of card (credit, debit, etc.)
        public let type: CardType
        
        /// Issuing bank code (for domestic cards)
        public let issuer: String?
        
        /// Whether card is eligible for EMI
        public let emi: Bool
        
        /// Card subtype (business or consumer)
        public let subType: SubType
        
        /// Card network
        public enum Network: String, Codable, Sendable {
            case visa = "Visa"
            case mastercard = "MasterCard"
            case amex = "American Express"
            case dinersClub = "Diners Club"
            case maestro = "Maestro"
            case rupay = "RuPay"
            case unknown = "Unknown"
        }
        
        /// Card type
        public enum CardType: String, Codable, Sendable {
            case credit
            case debit
            case prepaid
            case unknown
        }
        
        /// Card subtype
        public enum SubType: String, Codable, Sendable {
            case consumer = "customer"
            case business
        }
        
        private enum CodingKeys: String, CodingKey {
            case id
            case entity
            case name
            case last4
            case network
            case type
            case issuer
            case emi
            case subType = "sub_type"
        }
    }
    
    /// EMI details for the payment
    public struct EMIDetails: Codable, Sendable {
        /// The bank offering EMI
        public let bank: String
        
        /// Number of EMI installments
        public let tenure: Int
        
        /// Interest rate per annum
        public let interestRate: Double
        
        /// Amount per installment
        public let emiAmount: Int
        
        /// Total amount including interest
        public let totalAmount: Int
        
        /// Interest amount
        public let interestAmount: Int
        
        /// Description of the EMI plan
        public let description: String
        
        private enum CodingKeys: String, CodingKey {
            case bank
            case tenure
            case interestRate = "interest_rate"
            case emiAmount = "emi_amount"
            case totalAmount = "total_amount"
            case interestAmount = "interest_amount"
            case description
        }
    }
    
    /// Details about offers applied to the payment
    public struct OffersDetails: Codable, Sendable {
        /// Type of entity (always "collection")
        public let entity: String
        
        /// Number of offers applied
        public let count: Int
        
        /// List of applied offers
        public let items: [OfferItem]
        
        /// Individual offer item
        public struct OfferItem: Codable, Sendable {
            /// Unique identifier of the offer
            public let id: String
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case entity
        case amount
        case currency
        case status
        case orderId = "order_id"
        case invoiceId = "invoice_id"
        case international
        case method
        case amountRefunded = "amount_refunded"
        case refundStatus = "refund_status"
        case captured
        case description
        case cardId = "card_id"
        case bank
        case wallet
        case vpa
        case email
        case contact
        case customerId = "customer_id"
        case tokenId = "token_id"
        case notes
        case fee
        case tax
        case errorCode = "error_code"
        case errorDescription = "error_description"
        case errorSource = "error_source"
        case errorStep = "error_step"
        case errorReason = "error_reason"
        case acquirerData = "acquirer_data"
        case upi
        case createdAt = "created_at"
        case card
        case emi
        case offers
    }
}

/// Collection of payments for an order
public struct PaymentCollection: Codable, Sendable, RazorpayResponse {
    /// Type of entity (always "collection")
    public let entity: String
    
    /// Number of payments in the collection
    public let count: Int
    
    /// List of payments
    public let items: [Payment]
} 
