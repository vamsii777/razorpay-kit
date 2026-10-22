import Foundation
import RazorpayCore

/// A Route transfer of funds to a linked account. See https://razorpay.com/docs/api/payments/route/.
public struct Transfer: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RazorpayID<Transfer>

    public let id: ID
    public let status: Status
    /// The payment or order the funds come from (`pay_…`/`order_…`), or `nil` for direct transfers.
    public let source: String?
    public let recipient: LinkedAccount.ID
    public let amount: Money
    public let amountReversed: Money
    public let fees: Money?
    public let tax: Money?
    public let onHold: Bool
    public let onHoldUntil: Date?
    public let settlementStatus: SettlementStatus?
    public let recipientSettlementID: String?
    public let notes: Notes
    public let linkedAccountNotes: [String]
    public let failure: RazorpayError.APIError?
    public let processedAt: Date?
    public let createdAt: Date

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let created: Self = "created"
        public static let pending: Self = "pending"
        public static let processed: Self = "processed"
        public static let failed: Self = "failed"
        public static let reversed: Self = "reversed"
        public static let partiallyReversed: Self = "partially_reversed"
    }

    public struct SettlementStatus: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let pending: Self = "pending"
        public static let onHold: Self = "on_hold"
        public static let settled: Self = "settled"
    }

    enum CodingKeys: String, CodingKey {
        case id, status, source, recipient, amount, currency, fees, tax, notes, error
        case amountReversed = "amount_reversed", onHold = "on_hold", onHoldUntil = "on_hold_until"
        case settlementStatus = "settlement_status", recipientSettlementID = "recipient_settlement_id"
        case linkedAccountNotes = "linked_account_notes", processedAt = "processed_at", createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
        id = try c.decode(ID.self, forKey: .id)
        status = try c.decode(Status.self, forKey: .status)
        source = try c.decodeIfPresent(String.self, forKey: .source)
        recipient = try c.decode(LinkedAccount.ID.self, forKey: .recipient)
        amount = try c.decodeMoney(.amount, currency: currency)
        amountReversed = try c.decodeMoneyIfPresent(.amountReversed, currency: currency) ?? Money(amount: 0, currency: currency)
        fees = try c.decodeMoneyIfPresent(.fees, currency: currency)
        tax = try c.decodeMoneyIfPresent(.tax, currency: currency)
        onHold = try c.decodeFlagIfPresent(.onHold) ?? false
        onHoldUntil = try c.decodeIfPresent(Date.self, forKey: .onHoldUntil)
        settlementStatus = try c.decodeIfPresent(SettlementStatus.self, forKey: .settlementStatus)
        recipientSettlementID = try c.decodeIfPresent(String.self, forKey: .recipientSettlementID)
        notes = try NotesCoding.decode(c, .notes)
        linkedAccountNotes = (try? c.decodeIfPresent([String].self, forKey: .linkedAccountNotes)) ?? []
        // `error` is an object whose fields are all null when the transfer didn't fail.
        if let e = try? c.decodeIfPresent(RazorpayError.APIError.self, forKey: .error), e.code != nil {
            failure = e
        } else {
            failure = nil
        }
        processedAt = try c.decodeIfPresent(Date.self, forKey: .processedAt)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(source, forKey: .source)
        try c.encode(recipient, forKey: .recipient)
        try c.encodeMoney(amount, .amount)
        try c.encode(amount.currency, forKey: .currency)
        try c.encodeMoney(amountReversed, .amountReversed)
        try c.encodeMoney(fees, .fees)
        try c.encodeMoney(tax, .tax)
        try c.encode(onHold, forKey: .onHold)
        try c.encodeIfPresent(onHoldUntil, forKey: .onHoldUntil)
        try c.encodeIfPresent(settlementStatus, forKey: .settlementStatus)
        try c.encodeIfPresent(recipientSettlementID, forKey: .recipientSettlementID)
        try c.encode(notes, forKey: .notes)
        try c.encode(linkedAccountNotes, forKey: .linkedAccountNotes)
        try c.encodeIfPresent(failure, forKey: .error)
        try c.encodeIfPresent(processedAt, forKey: .processedAt)
        try c.encode(createdAt, forKey: .createdAt)
    }

    /// One transfer to create, from a payment or directly from your balance.
    public struct Create: Sendable, Hashable, Encodable {
        public var account: LinkedAccount.ID
        public var amount: Money
        public var notes: Notes
        /// Note keys copied onto the linked account's view of the transfer.
        public var linkedAccountNotes: [String]
        public var onHold: Bool
        public var onHoldUntil: Date?

        public init(account: LinkedAccount.ID, amount: Money, notes: Notes = [:], linkedAccountNotes: [String] = [],
                    onHold: Bool = false, onHoldUntil: Date? = nil) {
            self.account = account; self.amount = amount; self.notes = notes
            self.linkedAccountNotes = linkedAccountNotes; self.onHold = onHold; self.onHoldUntil = onHoldUntil
        }

        enum CodingKeys: String, CodingKey {
            case account, amount, currency, notes
            case linkedAccountNotes = "linked_account_notes", onHold = "on_hold", onHoldUntil = "on_hold_until"
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(account, forKey: .account)
            try c.encodeMoney(amount, .amount)
            try c.encode(amount.currency, forKey: .currency)
            try c.encodeNotes(notes, .notes)
            if !linkedAccountNotes.isEmpty { try c.encode(linkedAccountNotes, forKey: .linkedAccountNotes) }
            if onHold || onHoldUntil != nil { try c.encode(true, forKey: .onHold) }
            try c.encodeIfPresent(onHoldUntil, forKey: .onHoldUntil)
        }

        func validate() -> Result<Self, RazorpayError> {
            guard amount.amount > 0 else { return .failure(.invalidRequest("transfer amount must be positive")) }
            return account.pathComponent().map { _ in self }
        }
    }
}

/// A reversal of (part of) a transfer back to your balance.
public struct Reversal: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = RazorpayID<Reversal>

    public let id: ID
    public let transferID: Transfer.ID
    public let amount: Money
    public let fee: Money?
    public let tax: Money?
    public let notes: Notes
    public let initiatorID: String?
    public let customerRefundID: RefundID?
    public let utr: String?
    public let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, amount, currency, fee, tax, notes, utr
        case transferID = "transfer_id", initiatorID = "initiator_id", customerRefundID = "customer_refund_id", createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
        id = try c.decode(ID.self, forKey: .id)
        transferID = try c.decode(Transfer.ID.self, forKey: .transferID)
        amount = try c.decodeMoney(.amount, currency: currency)
        fee = try c.decodeMoneyIfPresent(.fee, currency: currency)
        tax = try c.decodeMoneyIfPresent(.tax, currency: currency)
        notes = try NotesCoding.decode(c, .notes)
        initiatorID = try c.decodeIfPresent(String.self, forKey: .initiatorID)
        customerRefundID = try c.decodeIfPresent(RefundID.self, forKey: .customerRefundID)
        utr = try c.decodeIfPresent(String.self, forKey: .utr)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(transferID, forKey: .transferID)
        try c.encodeMoney(amount, .amount)
        try c.encode(amount.currency, forKey: .currency)
        try c.encodeMoney(fee, .fee)
        try c.encodeMoney(tax, .tax)
        try c.encode(notes, forKey: .notes)
        try c.encodeIfPresent(initiatorID, forKey: .initiatorID)
        try c.encodeIfPresent(customerRefundID, forKey: .customerRefundID)
        try c.encodeIfPresent(utr, forKey: .utr)
        try c.encode(createdAt, forKey: .createdAt)
    }
}

extension Transfer: WebhookEntity { public static var payloadKey: String { "transfer" } }

extension RazorpayWebhook.Name {
    public static let transferProcessed: Self = "transfer.processed"
    public static let transferFailed: Self = "transfer.failed"
    public static let transferReversed: Self = "transfer.reversed"
    public static let settlementProcessed: Self = "settlement.processed"
}

struct TransfersBody: Encodable, Sendable { let transfers: [Transfer.Create] }
struct ReversalBody: Encodable, Sendable { let amount: Int?; var notes: Notes? }
struct HoldBody: Encodable, Sendable {
    let onHold: Bool; let onHoldUntil: Date?
    enum CodingKeys: String, CodingKey { case onHold = "on_hold", onHoldUntil = "on_hold_until" }
}

extension Transfer.Create {
    static func validateAll(_ transfers: [Self]) -> Result<[Self], RazorpayError> {
        var valid: [Self] = []
        for t in transfers {
            switch t.validate() {
            case .success(let v): valid.append(v)
            case .failure(let e): return .failure(e)
            }
        }
        return .success(valid)
    }
}
