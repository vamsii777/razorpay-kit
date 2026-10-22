import Foundation
import RazorpayCore

/// An invoice, a payment link with line items, or an e-commerce-on-delivery bill.
/// See https://razorpay.com/docs/api/payments/invoices/.
public struct Invoice: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = InvoiceID

    public let id: ID
    public let type: Kind?
    public let status: Status
    public let invoiceNumber: String?
    public let customerID: CustomerID?
    public let customerDetails: CustomerDetails?
    public let orderID: OrderID?
    public let paymentID: PaymentID?
    public let lineItems: [LineItem]
    /// The total. `nil` only for drafts without line items.
    public let amount: Money?
    public let amountPaid: Money?
    public let amountDue: Money?
    public let currency: Currency
    public let receipt: String?
    public let description: String?
    public let shortURL: String?
    public let partialPayment: Bool
    public let smsStatus: NotificationStatus?
    public let emailStatus: NotificationStatus?
    public let date: Date?
    public let issuedAt: Date?
    public let paidAt: Date?
    public let cancelledAt: Date?
    public let expiredAt: Date?
    public let expireBy: Date?
    public let notes: Notes
    public let createdAt: Date

    public struct Kind: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let invoice: Self = "invoice"
        public static let link: Self = "link"
        public static let ecod: Self = "ecod"
    }

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let draft: Self = "draft"
        public static let issued: Self = "issued"
        public static let partiallyPaid: Self = "partially_paid"
        public static let paid: Self = "paid"
        public static let cancelled: Self = "cancelled"
        public static let expired: Self = "expired"
        public static let deleted: Self = "deleted"
    }

    /// Whether an SMS or email notification went out.
    public struct NotificationStatus: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let pending: Self = "pending"
        public static let sent: Self = "sent"
    }

    /// Where to send a reminder with ``RazorpayClient/Invoices/notify(_:by:options:)``.
    public struct Medium: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let sms: Self = "sms"
        public static let email: Self = "email"
    }

    /// The customer as printed on the invoice.
    public struct CustomerDetails: Sendable, Hashable, Codable {
        public var name: String?
        public var email: String?
        public var contact: String?
        public var gstin: String?
        public var billingAddress: JSONValue?
        public var shippingAddress: JSONValue?

        public init(name: String? = nil, email: String? = nil, contact: String? = nil, gstin: String? = nil) {
            self.name = name
            self.email = email
            self.contact = contact
            self.gstin = gstin
        }

        enum CodingKeys: String, CodingKey {
            case name, email, contact, gstin
            case billingAddress = "billing_address", shippingAddress = "shipping_address"
        }

        enum ResponseKeys: String, CodingKey {
            case customerName = "customer_name", customerEmail = "customer_email", customerContact = "customer_contact"
        }

        /// Responses use `customer_name`-style keys on some accounts and `name`-style keys on others; both decode.
        public init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            let r = try decoder.container(keyedBy: ResponseKeys.self)
            name = try c.decodeIfPresent(String.self, forKey: .name) ?? r.decodeIfPresent(String.self, forKey: .customerName)
            email = try c.decodeIfPresent(String.self, forKey: .email) ?? r.decodeIfPresent(String.self, forKey: .customerEmail)
            contact = try c.decodeIfPresent(String.self, forKey: .contact) ?? r.decodeIfPresent(String.self, forKey: .customerContact)
            gstin = try c.decodeIfPresent(String.self, forKey: .gstin)
            billingAddress = try c.decodeIfPresent(JSONValue.self, forKey: .billingAddress)
            shippingAddress = try c.decodeIfPresent(JSONValue.self, forKey: .shippingAddress)
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeIfPresent(name, forKey: .name)
            try c.encodeIfPresent(email, forKey: .email)
            try c.encodeIfPresent(contact, forKey: .contact)
            try c.encodeIfPresent(gstin, forKey: .gstin)
            try c.encodeIfPresent(billingAddress, forKey: .billingAddress)
            try c.encodeIfPresent(shippingAddress, forKey: .shippingAddress)
        }
    }

    /// A line on the invoice.
    public struct LineItem: Sendable, Hashable, Decodable {
        public let id: String?
        public let itemID: ItemID?
        public let name: String
        public let description: String?
        public let amount: Money
        public let unitAmount: Money?
        public let grossAmount: Money?
        public let netAmount: Money?
        public let quantity: Int

        enum CodingKeys: String, CodingKey {
            case id, name, description, amount, currency, quantity
            case itemID = "item_id", unitAmount = "unit_amount", grossAmount = "gross_amount", netAmount = "net_amount"
        }

        public init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            let currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
            id = try c.decodeIfPresent(String.self, forKey: .id)
            itemID = try c.decodeIfPresent(ItemID.self, forKey: .itemID)
            name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
            description = try c.decodeIfPresent(String.self, forKey: .description)
            amount = try c.decodeMoney(.amount, currency: currency)
            unitAmount = try c.decodeMoneyIfPresent(.unitAmount, currency: currency)
            grossAmount = try c.decodeMoneyIfPresent(.grossAmount, currency: currency)
            netAmount = try c.decodeMoneyIfPresent(.netAmount, currency: currency)
            quantity = try c.decodeIfPresent(Int.self, forKey: .quantity) ?? 1
        }
    }

    /// A line to bill: either an existing item or an ad-hoc name and price.
    public struct LineItemInput: Sendable, Hashable, Encodable {
        public var itemID: ItemID?
        public var name: String?
        public var description: String?
        public var amount: Money?
        public var quantity: Int?

        /// Bills an existing item.
        public static func item(_ id: ItemID, quantity: Int? = nil) -> Self {
            Self(itemID: id, quantity: quantity)
        }

        /// Bills an ad-hoc line.
        public static func custom(name: String, amount: Money, description: String? = nil, quantity: Int? = nil) -> Self {
            Self(name: name, description: description, amount: amount, quantity: quantity)
        }

        public init(itemID: ItemID? = nil, name: String? = nil, description: String? = nil, amount: Money? = nil, quantity: Int? = nil) {
            self.itemID = itemID
            self.name = name
            self.description = description
            self.amount = amount
            self.quantity = quantity
        }

        enum CodingKeys: String, CodingKey { case itemID = "item_id", name, description, amount, currency, quantity }
        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeIfPresent(itemID, forKey: .itemID)
            try c.encodeIfPresent(name, forKey: .name)
            try c.encodeIfPresent(description, forKey: .description)
            try c.encodeIfPresent(amount?.amount, forKey: .amount)
            try c.encodeIfPresent(amount?.currency, forKey: .currency)
            try c.encodeIfPresent(quantity, forKey: .quantity)
        }
    }

    /// The body for ``RazorpayClient/Invoices/create(_:options:)``. Pass either `customerID` or `customer`.
    public struct Create: Sendable, Hashable, Encodable {
        public var type: Kind
        public var description: String?
        public var customerID: CustomerID?
        public var customer: CustomerDetails?
        public var lineItems: [LineItemInput]
        public var currency: Currency?
        public var receipt: String?
        public var expireBy: Date?
        public var smsNotify: Bool?
        public var emailNotify: Bool?
        public var partialPayment: Bool?
        /// `true` creates a draft you issue later with ``RazorpayClient/Invoices/issue(_:options:)``.
        public var draft: Bool
        public var notes: Notes

        public init(type: Kind = .invoice, description: String? = nil, customerID: CustomerID? = nil, customer: CustomerDetails? = nil,
                    lineItems: [LineItemInput], currency: Currency? = nil, receipt: String? = nil, expireBy: Date? = nil,
                    smsNotify: Bool? = nil, emailNotify: Bool? = nil, partialPayment: Bool? = nil, draft: Bool = false, notes: Notes = [:]) {
            self.type = type
            self.description = description
            self.customerID = customerID
            self.customer = customer
            self.lineItems = lineItems
            self.currency = currency
            self.receipt = receipt
            self.expireBy = expireBy
            self.smsNotify = smsNotify
            self.emailNotify = emailNotify
            self.partialPayment = partialPayment
            self.draft = draft
            self.notes = notes
        }

        enum CodingKeys: String, CodingKey {
            case type, description, customer, currency, receipt, notes, draft
            case customerID = "customer_id", lineItems = "line_items", expireBy = "expire_by"
            case smsNotify = "sms_notify", emailNotify = "email_notify", partialPayment = "partial_payment"
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(type, forKey: .type)
            try c.encodeIfPresent(description, forKey: .description)
            try c.encodeIfPresent(customerID, forKey: .customerID)
            try c.encodeIfPresent(customer, forKey: .customer)
            try c.encode(lineItems, forKey: .lineItems)
            try c.encodeIfPresent(currency, forKey: .currency)
            try c.encodeIfPresent(receipt, forKey: .receipt)
            try c.encodeIfPresent(expireBy.map { Int($0.timeIntervalSince1970) }, forKey: .expireBy)
            try c.encodeIfPresent(smsNotify.map { $0 ? 1 : 0 }, forKey: .smsNotify)
            try c.encodeIfPresent(emailNotify.map { $0 ? 1 : 0 }, forKey: .emailNotify)
            try c.encodeIfPresent(partialPayment, forKey: .partialPayment)
            if draft { try c.encode("1", forKey: .draft) }
            if !notes.isEmpty { try c.encode(notes, forKey: .notes) }
        }
    }

    /// Fields to change. Issued invoices only accept `notes`, `receipt`, `description` and `expireBy`;
    /// drafts accept everything. Only non-nil fields are sent.
    public struct Update: Sendable, Hashable, Encodable {
        public var description: String?
        public var customerID: CustomerID?
        public var customer: CustomerDetails?
        public var lineItems: [LineItemInput]?
        public var receipt: String?
        public var expireBy: Date?
        public var partialPayment: Bool?
        public var notes: Notes?

        public init(description: String? = nil, customerID: CustomerID? = nil, customer: CustomerDetails? = nil, lineItems: [LineItemInput]? = nil,
                    receipt: String? = nil, expireBy: Date? = nil, partialPayment: Bool? = nil, notes: Notes? = nil) {
            self.description = description
            self.customerID = customerID
            self.customer = customer
            self.lineItems = lineItems
            self.receipt = receipt
            self.expireBy = expireBy
            self.partialPayment = partialPayment
            self.notes = notes
        }

        enum CodingKeys: String, CodingKey {
            case description, customer, receipt, notes
            case customerID = "customer_id", lineItems = "line_items", expireBy = "expire_by", partialPayment = "partial_payment"
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeIfPresent(description, forKey: .description)
            try c.encodeIfPresent(customerID, forKey: .customerID)
            try c.encodeIfPresent(customer, forKey: .customer)
            try c.encodeIfPresent(lineItems, forKey: .lineItems)
            try c.encodeIfPresent(receipt, forKey: .receipt)
            try c.encodeIfPresent(expireBy.map { Int($0.timeIntervalSince1970) }, forKey: .expireBy)
            try c.encodeIfPresent(partialPayment, forKey: .partialPayment)
            try c.encodeIfPresent(notes, forKey: .notes)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, type, status, amount, currency, receipt, description, date, notes
        case invoiceNumber = "invoice_number", customerID = "customer_id", customerDetails = "customer_details"
        case orderID = "order_id", paymentID = "payment_id", lineItems = "line_items", amountPaid = "amount_paid", amountDue = "amount_due"
        case shortURL = "short_url", partialPayment = "partial_payment", smsStatus = "sms_status", emailStatus = "email_status"
        case issuedAt = "issued_at", paidAt = "paid_at", cancelledAt = "cancelled_at", expiredAt = "expired_at", expireBy = "expire_by"
        case createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
        id = try c.decode(ID.self, forKey: .id)
        type = try c.decodeIfPresent(Kind.self, forKey: .type)
        status = try c.decode(Status.self, forKey: .status)
        invoiceNumber = try c.decodeIfPresent(String.self, forKey: .invoiceNumber)
        customerID = try c.decodeIfPresent(CustomerID.self, forKey: .customerID)
        customerDetails = try c.decodeIfPresent(CustomerDetails.self, forKey: .customerDetails)
        orderID = try c.decodeIfPresent(OrderID.self, forKey: .orderID)
        paymentID = try c.decodeIfPresent(PaymentID.self, forKey: .paymentID)
        lineItems = try c.decodeIfPresent([LineItem].self, forKey: .lineItems) ?? []
        amount = try c.decodeMoneyIfPresent(.amount, currency: currency)
        amountPaid = try c.decodeMoneyIfPresent(.amountPaid, currency: currency)
        amountDue = try c.decodeMoneyIfPresent(.amountDue, currency: currency)
        receipt = try c.decodeIfPresent(String.self, forKey: .receipt)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        shortURL = try c.decodeIfPresent(String.self, forKey: .shortURL)
        partialPayment = try c.decodeIfPresent(Bool.self, forKey: .partialPayment) ?? false
        smsStatus = try c.decodeIfPresent(NotificationStatus.self, forKey: .smsStatus)
        emailStatus = try c.decodeIfPresent(NotificationStatus.self, forKey: .emailStatus)
        date = try c.decodeIfPresent(Date.self, forKey: .date)
        issuedAt = try c.decodeIfPresent(Date.self, forKey: .issuedAt)
        paidAt = try c.decodeIfPresent(Date.self, forKey: .paidAt)
        cancelledAt = try c.decodeIfPresent(Date.self, forKey: .cancelledAt)
        expiredAt = try c.decodeIfPresent(Date.self, forKey: .expiredAt)
        expireBy = try c.decodeIfPresent(Date.self, forKey: .expireBy)
        notes = try NotesCoding.decode(c, .notes)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}

extension Invoice: WebhookEntity { public static var payloadKey: String { "invoice" } }

extension RazorpayWebhook.Name {
    public static let invoicePaid: Self = "invoice.paid"
    public static let invoicePartiallyPaid: Self = "invoice.partially_paid"
    public static let invoiceExpired: Self = "invoice.expired"
}
