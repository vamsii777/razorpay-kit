import Foundation
import RazorpayCore

/// A Smart Collect virtual account: bank account, UPI ID or QR receivers that collect payments for one customer.
/// See https://razorpay.com/docs/api/payments/smart-collect/.
public struct VirtualAccount: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RazorpayID<VirtualAccount>

    public let id: ID
    public let name: String?
    public let status: Status
    public let description: String?
    public let amountExpected: Money?
    public let amountPaid: Money
    public let customerID: CustomerID?
    public let receivers: [Receiver]
    public let allowedPayers: [AllowedPayer]
    public let notes: Notes
    public let closeBy: Date?
    public let closedAt: Date?
    public let createdAt: Date

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let active: Self = "active"
        public static let paid: Self = "paid"
        public static let closed: Self = "closed"
    }

    /// One way to pay into the account.
    public enum Receiver: Sendable, Hashable, Codable {
        case bankAccount(BankAccount)
        case vpa(id: String?, VPAAddress)
        case qrCode(id: String?, imageURL: String?)
        /// A receiver kind this SDK doesn't model yet.
        case other(entity: String, JSONValue)

        public struct Kind: RazorpayStringEnum {
            public let rawValue: String
            public init(rawValue: String) { self.rawValue = rawValue }
            public static let bankAccount: Self = "bank_account"
            public static let vpa: Self = "vpa"
            public static let qrCode: Self = "qr_code"
        }

        public init(from decoder: any Decoder) throws {
            let raw = try JSONValue(from: decoder)
            guard case .object(let o) = raw, case .string(let entity)? = o["entity"] else {
                self = .other(entity: "", raw); return
            }
            func s(_ k: String) -> String? { if case .string(let v)? = o[k] { return v } else { return nil } }
            switch entity {
            case Kind.bankAccount.rawValue: self = .bankAccount(try BankAccount(from: decoder))
            case Kind.vpa.rawValue: self = .vpa(id: s("id"), try VPAAddress(from: decoder))
            case Kind.qrCode.rawValue: self = .qrCode(id: s("id"), imageURL: s("short_url") ?? s("image_url"))
            default: self = .other(entity: entity, raw)
            }
        }

        public func encode(to encoder: any Encoder) throws {
            var json: [String: JSONValue]
            switch self {
            case .bankAccount(let b):
                json = try RazorpayCoding.decoder.decode([String: JSONValue].self, from: RazorpayCoding.encoder.encode(b))
                json["entity"] = .string(Kind.bankAccount.rawValue)
            case .vpa(let id, let v):
                json = try RazorpayCoding.decoder.decode([String: JSONValue].self, from: RazorpayCoding.encoder.encode(v))
                json["entity"] = .string(Kind.vpa.rawValue)
                if let id { json["id"] = .string(id) }
            case .qrCode(let id, let url):
                json = ["entity": .string(Kind.qrCode.rawValue)]
                if let id { json["id"] = .string(id) }
                if let url { json["short_url"] = .string(url) }
            case .other(_, let raw):
                try raw.encode(to: encoder); return
            }
            try json.encode(to: encoder)
        }
    }

    /// A TPV (third-party validation) payer: only these bank accounts may pay in.
    public struct AllowedPayer: Sendable, Hashable, Codable {
        public let id: String?
        public let type: String
        public let bankAccount: BankAccount?

        public init(id: String? = nil, bankAccount: BankAccount) {
            self.id = id; self.type = "bank_account"; self.bankAccount = bankAccount
        }

        enum CodingKeys: String, CodingKey { case id, type, bankAccount = "bank_account" }
    }

    enum CodingKeys: String, CodingKey {
        case id, name, status, description, notes, receivers
        case amountExpected = "amount_expected", amountPaid = "amount_paid", customerID = "customer_id"
        case allowedPayers = "allowed_payers", closeBy = "close_by", closedAt = "closed_at", createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        status = try c.decode(Status.self, forKey: .status)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        amountExpected = try c.decodeMoneyIfPresent(.amountExpected, currency: .inr)
        amountPaid = try c.decodeMoneyIfPresent(.amountPaid, currency: .inr) ?? .inr(paise: 0)
        customerID = try c.decodeIfPresent(CustomerID.self, forKey: .customerID)
        receivers = try c.decodeIfPresent([Receiver].self, forKey: .receivers) ?? []
        allowedPayers = try c.decodeIfPresent([AllowedPayer].self, forKey: .allowedPayers) ?? []
        notes = try NotesCoding.decode(c, .notes)
        closeBy = try c.decodeIfPresent(Date.self, forKey: .closeBy)
        closedAt = try c.decodeIfPresent(Date.self, forKey: .closedAt)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encodeIfPresent(name, forKey: .name)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(description, forKey: .description)
        try c.encodeMoney(amountExpected, .amountExpected)
        try c.encodeMoney(amountPaid, .amountPaid)
        try c.encodeIfPresent(customerID, forKey: .customerID)
        try c.encode(receivers, forKey: .receivers)
        try c.encode(allowedPayers, forKey: .allowedPayers)
        try c.encode(notes, forKey: .notes)
        try c.encodeIfPresent(closeBy, forKey: .closeBy)
        try c.encodeIfPresent(closedAt, forKey: .closedAt)
        try c.encode(createdAt, forKey: .createdAt)
    }

    /// The bank account receiver, if any.
    public var bankAccount: BankAccount? {
        for r in receivers { if case .bankAccount(let b) = r { return b } }
        return nil
    }

    /// The UPI receiver, if any.
    public var vpa: VPAAddress? {
        for r in receivers { if case .vpa(_, let v) = r { return v } }
        return nil
    }

    /// `POST /v1/virtual_accounts`.
    public struct Create: Sendable, Hashable, Encodable {
        public var receivers: Set<Receiver.Kind>
        /// Optional prefix for the generated UPI ID (`vpa` receivers only).
        public var vpaDescriptor: String?
        public var description: String?
        public var customerID: CustomerID?
        public var amountExpected: Money?
        public var allowedPayers: [AllowedPayer]
        public var closeBy: Date?
        public var notes: Notes

        public init(receivers: Set<Receiver.Kind>, vpaDescriptor: String? = nil, description: String? = nil,
                    customerID: CustomerID? = nil, amountExpected: Money? = nil, allowedPayers: [AllowedPayer] = [],
                    closeBy: Date? = nil, notes: Notes = [:]) {
            self.receivers = receivers; self.vpaDescriptor = vpaDescriptor; self.description = description
            self.customerID = customerID; self.amountExpected = amountExpected; self.allowedPayers = allowedPayers
            self.closeBy = closeBy; self.notes = notes
        }

        enum Keys: String, CodingKey {
            case receivers, description, notes, customerID = "customer_id", amountExpected = "amount_expected"
            case allowedPayers = "allowed_payers", closeBy = "close_by"
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: Keys.self)
            try c.encode(ReceiversBody(receivers, vpaDescriptor), forKey: .receivers)
            try c.encodeIfPresent(description, forKey: .description)
            try c.encodeIfPresent(customerID, forKey: .customerID)
            try c.encodeMoney(amountExpected, .amountExpected)
            if !allowedPayers.isEmpty { try c.encode(allowedPayers, forKey: .allowedPayers) }
            try c.encodeIfPresent(closeBy, forKey: .closeBy)
            try c.encodeNotes(notes, .notes)
        }

        func validate() -> Result<Self, RazorpayError> {
            guard !receivers.isEmpty else { return .failure(.invalidRequest("at least one receiver type is required")) }
            if let a = amountExpected, a.currency != .inr || a.amount <= 0 {
                return .failure(.invalidRequest("amountExpected must be a positive INR amount"))
            }
            return .success(self)
        }
    }
}

/// `{"types": [...], "vpa": {"descriptor": ...}}`, sorted for stable bodies.
struct ReceiversBody: Encodable, Sendable {
    let types: [String]
    let vpa: [String: String]?
    init(_ kinds: Set<VirtualAccount.Receiver.Kind>, _ descriptor: String?) {
        types = kinds.map(\.rawValue).sorted()
        vpa = descriptor.flatMap { kinds.contains(.vpa) ? ["descriptor": $0] : nil }
    }
}

/// How a bank transfer into a virtual account was made. See `GET /v1/payments/:id/bank_transfer`.
public struct BankTransfer: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RazorpayID<BankTransfer>

    public let id: ID
    public let paymentID: PaymentID
    public let mode: String?
    public let bankReference: String?
    public let amount: Money
    public let payerBankAccount: BankAccount?
    public let virtualAccountID: VirtualAccount.ID?

    enum CodingKeys: String, CodingKey {
        case id, mode, amount, paymentID = "payment_id", bankReference = "bank_reference"
        case payerBankAccount = "payer_bank_account", virtualAccountID = "virtual_account_id"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        paymentID = try c.decode(PaymentID.self, forKey: .paymentID)
        mode = try c.decodeIfPresent(String.self, forKey: .mode)
        bankReference = try c.decodeIfPresent(String.self, forKey: .bankReference)
        amount = try c.decodeMoney(.amount, currency: .inr)
        payerBankAccount = try c.decodeIfPresent(BankAccount.self, forKey: .payerBankAccount)
        virtualAccountID = try c.decodeIfPresent(VirtualAccount.ID.self, forKey: .virtualAccountID)
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(paymentID, forKey: .paymentID)
        try c.encodeIfPresent(mode, forKey: .mode)
        try c.encodeIfPresent(bankReference, forKey: .bankReference)
        try c.encodeMoney(amount, .amount)
        try c.encodeIfPresent(payerBankAccount, forKey: .payerBankAccount)
        try c.encodeIfPresent(virtualAccountID, forKey: .virtualAccountID)
    }
}

extension VirtualAccount: WebhookEntity { public static var payloadKey: String { "virtual_account" } }
extension BankTransfer: WebhookEntity { public static var payloadKey: String { "bank_transfer" } }

extension RazorpayWebhook.Name {
    public static let virtualAccountCreated: Self = "virtual_account.created"
    public static let virtualAccountCredited: Self = "virtual_account.credited"
    public static let virtualAccountClosed: Self = "virtual_account.closed"
}

/// A customer's payout destination: a bank account or UPI ID. See https://razorpay.com/docs/api/payments/fund-accounts/.
public struct FundAccount: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RazorpayID<FundAccount>

    public let id: ID
    public let customerID: CustomerID?
    public let accountType: Kind
    public let bankAccount: BankAccount?
    public let vpa: VPAAddress?
    public let active: Bool
    public let createdAt: Date

    public struct Kind: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let bankAccount: Self = "bank_account"
        public static let vpa: Self = "vpa"
    }

    enum CodingKeys: String, CodingKey {
        case id, vpa, active, customerID = "customer_id", accountType = "account_type"
        case bankAccount = "bank_account", createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        customerID = try c.decodeIfPresent(CustomerID.self, forKey: .customerID)
        accountType = try c.decode(Kind.self, forKey: .accountType)
        bankAccount = try c.decodeIfPresent(BankAccount.self, forKey: .bankAccount)
        vpa = try c.decodeIfPresent(VPAAddress.self, forKey: .vpa)
        active = try c.decodeFlagIfPresent(.active) ?? true
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }

    /// The destination of a new fund account.
    public enum Destination: Sendable, Hashable {
        case bankAccount(name: String, ifsc: String, accountNumber: String)
        case vpa(String)
    }
}

struct FundAccountBody: Encodable, Sendable {
    let customer: CustomerID
    let destination: FundAccount.Destination
    enum Keys: String, CodingKey { case customerID = "customer_id", accountType = "account_type", bankAccount = "bank_account", vpa }
    func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: Keys.self)
        try c.encode(customer, forKey: .customerID)
        switch destination {
        case .bankAccount(let name, let ifsc, let number):
            try c.encode(FundAccount.Kind.bankAccount, forKey: .accountType)
            try c.encode(["name": name, "ifsc": ifsc.uppercased(), "account_number": number], forKey: .bankAccount)
        case .vpa(let address):
            try c.encode(FundAccount.Kind.vpa, forKey: .accountType)
            try c.encode(["address": address], forKey: .vpa)
        }
    }
    func validate() -> Result<Self, RazorpayError> {
        switch destination {
        case .bankAccount(let name, let ifsc, let number):
            let ifscOK = ifsc.count == 11 && ifsc.allSatisfy { $0.isLetter || $0.isNumber }
            guard !name.isEmpty, ifscOK, !number.isEmpty, number.allSatisfy(\.isNumber) else {
                return .failure(.invalidRequest("bank account needs a name, an 11-character IFSC and a numeric account number"))
            }
        case .vpa(let address):
            guard address.split(separator: "@").count == 2 else { return .failure(.invalidRequest("VPA must look like name@handle")) }
        }
        return customer.pathComponent().map { _ in self }
    }
}
