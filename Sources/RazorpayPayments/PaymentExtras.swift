import Foundation
import RazorpayCore

/// The result of ``RazorpayClient/Payments/validateVPA(_:options:)``.
public struct VPAValidation: Sendable, Hashable, Codable {
    public let vpa: String
    /// `true` when the UPI ID exists and can receive collect requests.
    public let success: Bool
    /// The account holder's name, when the VPA is valid.
    public let customerName: String?

    public init(vpa: String, success: Bool, customerName: String? = nil) {
        self.vpa = vpa; self.success = success; self.customerName = customerName
    }

    enum CodingKeys: String, CodingKey { case vpa, success, customerName = "customer_name" }
}

/// A card used for a payment (never the full number). See https://razorpay.com/docs/api/payments/fetch-card-details/.
public struct Card: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = CardID

    public let id: ID
    public let name: String?
    public let last4: String?
    public let network: Network?
    public let type: Kind?
    public let issuer: String?
    public let international: Bool
    public let emi: Bool
    public let subType: String?
    public let tokenIIN: String?

    public init(id: ID, name: String? = nil, last4: String? = nil, network: Network? = nil, type: Kind? = nil,
                issuer: String? = nil, international: Bool = false, emi: Bool = false,
                subType: String? = nil, tokenIIN: String? = nil) {
        self.id = id; self.name = name; self.last4 = last4; self.network = network; self.type = type
        self.issuer = issuer; self.international = international; self.emi = emi
        self.subType = subType; self.tokenIIN = tokenIIN
    }

    /// Card network, for example `Visa` or `MasterCard`, exactly as Razorpay names it.
    public struct Network: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let amex: Self = "American Express"
        public static let dinersClub: Self = "Diners Club"
        public static let maestro: Self = "Maestro"
        public static let mastercard: Self = "MasterCard"
        public static let rupay: Self = "RuPay"
        public static let visa: Self = "Visa"
        public static let bajaj: Self = "Bajaj Finserv"
        public static let unknown: Self = "Unknown"
    }

    public struct Kind: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let credit: Self = "credit"
        public static let debit: Self = "debit"
        public static let prepaid: Self = "prepaid"
        public static let unknown: Self = "unknown"
    }

    enum CodingKeys: String, CodingKey {
        case id, name, last4, network, type, issuer, international, emi
        case subType = "sub_type", tokenIIN = "token_iin"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        last4 = try c.decodeIfPresent(String.self, forKey: .last4)
        network = try c.decodeIfPresent(Network.self, forKey: .network)
        type = try c.decodeIfPresent(Kind.self, forKey: .type)
        issuer = try c.decodeIfPresent(String.self, forKey: .issuer)
        international = try c.decodeFlagIfPresent(.international) ?? false
        emi = try c.decodeFlagIfPresent(.emi) ?? false
        subType = try c.decodeIfPresent(String.self, forKey: .subType)
        tokenIIN = try c.decodeIfPresent(String.self, forKey: .tokenIIN)
    }
}

/// The payment methods enabled on the account (`GET /v1/methods`).
public struct PaymentMethods: Sendable, Hashable, Codable {
    public let card: Bool
    public let debitCard: Bool
    public let creditCard: Bool
    public let prepaidCard: Bool
    public let upi: Bool
    public let emi: Bool
    /// Enabled card networks, keyed by Razorpay's code (`VISA`, `MC`, …).
    public let cardNetworks: [String: Bool]
    /// Bank code → display name.
    public let netbanking: [String: String]
    /// Wallet code → enabled.
    public let wallets: [String: Bool]
    /// The full response, for methods not modelled above (cardless EMI, pay later, recurring, …).
    public let raw: [String: JSONValue]

    public init(card: Bool = false, debitCard: Bool = false, creditCard: Bool = false, prepaidCard: Bool = false,
                upi: Bool = false, emi: Bool = false, cardNetworks: [String: Bool] = [:],
                netbanking: [String: String] = [:], wallets: [String: Bool] = [:], raw: [String: JSONValue] = [:]) {
        self.card = card; self.debitCard = debitCard; self.creditCard = creditCard; self.prepaidCard = prepaidCard
        self.upi = upi; self.emi = emi; self.cardNetworks = cardNetworks
        self.netbanking = netbanking; self.wallets = wallets; self.raw = raw
    }

    public init(from decoder: any Decoder) throws {
        let raw = try [String: JSONValue](from: decoder)
        self.raw = raw
        func flag(_ k: String) -> Bool {
            switch raw[k] {
            case .bool(let b)?: return b
            case .int(let n)?: return n != 0
            default: return false
            }
        }
        func flags(_ k: String) -> [String: Bool] {
            guard case .object(let o)? = raw[k] else { return [:] }
            return o.mapValues { v in
                switch v { case .bool(let b): return b; case .int(let n): return n != 0; default: return false }
            }
        }
        card = flag("card"); debitCard = flag("debit_card"); creditCard = flag("credit_card")
        prepaidCard = flag("prepaid_card"); upi = flag("upi"); emi = flag("emi")
        cardNetworks = flags("card_networks"); wallets = flags("wallet")
        if case .object(let o)? = raw["netbanking"] {
            netbanking = o.compactMapValues { if case .string(let s) = $0 { return s } else { return nil } }
        } else {
            netbanking = [:]
        }
    }

    public func encode(to encoder: any Encoder) throws { try raw.encode(to: encoder) }
}

/// What the customer or your server must do next for an S2S payment, for example `redirect` or `otp_submit`.
public struct PaymentAction: Sendable, Hashable, Codable {
    public let action: Action
    public let url: String?

    public init(action: Action, url: String? = nil) { self.action = action; self.url = url }

    public struct Action: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let redirect: Self = "redirect"
        public static let otpGenerate: Self = "otp_generate"
        public static let otpSubmit: Self = "otp_submit"
        public static let otpResend: Self = "otp_resend"
        public static let poll: Self = "poll"
        public static let intent: Self = "intent"
    }
}

/// The response to S2S payment calls: JSON and recurring creation, OTP generate/submit/resend.
/// Verify ``signature`` with `razorpay.webhooks`/`Signatures` before trusting a captured payment.
public struct PaymentResult: Sendable, Hashable, Codable {
    public let paymentID: PaymentID
    public let orderID: OrderID?
    /// `razorpay_signature`, present once the payment is authorized.
    public let signature: String?
    /// Next steps, empty when there are none.
    public let next: [PaymentAction]
    /// Extra fields (for example OTP `metadata`).
    public let metadata: [String: JSONValue]

    public init(paymentID: PaymentID, orderID: OrderID? = nil, signature: String? = nil,
                next: [PaymentAction] = [], metadata: [String: JSONValue] = [:]) {
        self.paymentID = paymentID; self.orderID = orderID; self.signature = signature
        self.next = next; self.metadata = metadata
    }

    enum CodingKeys: String, CodingKey {
        case paymentID = "razorpay_payment_id", orderID = "razorpay_order_id", signature = "razorpay_signature"
        case next, metadata
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        paymentID = try c.decode(PaymentID.self, forKey: .paymentID)
        orderID = try c.decodeIfPresent(OrderID.self, forKey: .orderID)
        signature = try c.decodeIfPresent(String.self, forKey: .signature)
        next = try c.decodeIfPresent([PaymentAction].self, forKey: .next) ?? []
        metadata = (try? c.decodeIfPresent([String: JSONValue].self, forKey: .metadata)) ?? [:]
    }
}

/// `POST /v1/payments/create/json`: an S2S payment. Method-specific fields (card, UPI, bank…)
/// go in ``details`` with Razorpay's key names. See https://razorpay.com/docs/payments/payment-gateway/s2s-integration/json/.
public struct PaymentRequest: Sendable, Hashable, Encodable {
    public var amount: Money
    public var orderID: OrderID
    public var method: Payment.Method
    public var email: String
    public var contact: String
    public var customerID: CustomerID?
    public var callbackURL: String?
    public var ip: String?
    public var userAgent: String?
    public var referer: String?
    public var notes: Notes
    /// Extra top-level fields, for example `["vpa": "user@upi"]` or `["card": [...]]`.
    public var details: [String: JSONValue]

    public init(amount: Money, orderID: OrderID, method: Payment.Method, email: String, contact: String,
                customerID: CustomerID? = nil, callbackURL: String? = nil, ip: String? = nil, userAgent: String? = nil,
                referer: String? = nil, notes: Notes = [:], details: [String: JSONValue] = [:]) {
        self.amount = amount; self.orderID = orderID; self.method = method; self.email = email; self.contact = contact
        self.customerID = customerID; self.callbackURL = callbackURL; self.ip = ip; self.userAgent = userAgent
        self.referer = referer; self.notes = notes; self.details = details
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: AnyCodingKey.self)
        // Typed fields win over `details` keys of the same name.
        let typed: Set<String> = ["amount", "currency", "order_id", "method", "email", "contact", "customer_id",
                                  "callback_url", "ip", "user_agent", "referer", "notes"]
        for (k, v) in details where !typed.contains(k) { try c.encode(v, forKey: AnyCodingKey(k)) }
        try c.encode(amount.amount, forKey: AnyCodingKey("amount"))
        try c.encode(amount.currency, forKey: AnyCodingKey("currency"))
        try c.encode(orderID, forKey: AnyCodingKey("order_id"))
        try c.encode(method, forKey: AnyCodingKey("method"))
        try c.encode(email, forKey: AnyCodingKey("email"))
        try c.encode(contact, forKey: AnyCodingKey("contact"))
        try c.encodeIfPresent(customerID, forKey: AnyCodingKey("customer_id"))
        try c.encodeIfPresent(callbackURL, forKey: AnyCodingKey("callback_url"))
        try c.encodeIfPresent(ip, forKey: AnyCodingKey("ip"))
        try c.encodeIfPresent(userAgent, forKey: AnyCodingKey("user_agent"))
        try c.encodeIfPresent(referer, forKey: AnyCodingKey("referer"))
        if !notes.isEmpty { try c.encode(notes, forKey: AnyCodingKey("notes")) }
    }
}

/// `POST /v1/payments/create/recurring`: charges a saved token (card, eMandate, NACH or UPI AutoPay).
public struct RecurringPaymentRequest: Sendable, Hashable, Encodable {
    public var amount: Money
    public var orderID: OrderID
    public var customerID: CustomerID
    /// The token ID (`token_…`) from the authorization payment.
    public var token: String
    public var email: String
    public var contact: String
    public var description: String?
    public var notes: Notes

    public init(amount: Money, orderID: OrderID, customerID: CustomerID, token: String, email: String,
                contact: String, description: String? = nil, notes: Notes = [:]) {
        self.amount = amount; self.orderID = orderID; self.customerID = customerID; self.token = token
        self.email = email; self.contact = contact; self.description = description; self.notes = notes
    }

    enum CodingKeys: String, CodingKey {
        case amount, currency, token, email, contact, description, notes, recurring
        case orderID = "order_id", customerID = "customer_id"
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(amount.amount, forKey: .amount)
        try c.encode(amount.currency, forKey: .currency)
        try c.encode(orderID, forKey: .orderID)
        try c.encode(customerID, forKey: .customerID)
        try c.encode(token, forKey: .token)
        try c.encode(email, forKey: .email)
        try c.encode(contact, forKey: .contact)
        try c.encode("1", forKey: .recurring)
        try c.encodeIfPresent(description, forKey: .description)
        if !notes.isEmpty { try c.encode(notes, forKey: .notes) }
    }
}

struct VPABody: Encodable, Sendable { let vpa: String }
struct OTPBody: Encodable, Sendable { let otp: String }

/// Trims `value` and fails with `.invalidRequest` when it is empty.
func required(_ value: String, _ what: String) -> Result<String, RazorpayError> {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? .failure(.invalidRequest("\(what) is empty")) : .success(trimmed)
}
