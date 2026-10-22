import Foundation
import RazorpayCore

/// A transfer of your collected balance to your bank account. See https://razorpay.com/docs/api/settlements/.
public struct Settlement: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = SettlementID

    public let id: ID
    public let amount: Money
    public let status: Status
    public let fees: Money?
    public let tax: Money?
    /// The bank reference number, once processed.
    public let utr: String?
    public let createdAt: Date

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let created: Self = "created"
        public static let processed: Self = "processed"
        public static let failed: Self = "failed"
    }

    enum CodingKeys: String, CodingKey { case id, amount, currency, status, fees, tax, utr, createdAt = "created_at" }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
        id = try c.decode(ID.self, forKey: .id)
        amount = try c.decodeMoney(.amount, currency: currency)
        status = try c.decode(Status.self, forKey: .status)
        fees = try c.decodeMoneyIfPresent(.fees, currency: currency)
        tax = try c.decodeMoneyIfPresent(.tax, currency: currency)
        utr = try c.decodeIfPresent(String.self, forKey: .utr)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}

extension Settlement: WebhookEntity { public static var payloadKey: String { "settlement" } }

/// An instant (on-demand) settlement. See https://razorpay.com/docs/api/settlements/instant/.
public struct InstantSettlement: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = InstantSettlementID

    public let id: ID
    public let amountRequested: Money
    public let amountSettled: Money?
    public let amountPending: Money?
    public let amountReversed: Money?
    public let fees: Money?
    public let tax: Money?
    public let settleFullBalance: Bool
    public let status: Status
    public let description: String?
    public let notes: Notes
    /// The payouts that make up this settlement, when fetched with `expand[]=ondemand_payouts`.
    public let payouts: [Payout]
    public let createdAt: Date

    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let created: Self = "created"
        public static let initiated: Self = "initiated"
        public static let partiallyProcessed: Self = "partially_processed"
        public static let processed: Self = "processed"
        public static let reversed: Self = "reversed"
    }

    /// One payout of an instant settlement.
    public struct Payout: Sendable, Hashable, Identifiable, Decodable {
        public let id: String
        public let amount: Money
        public let fees: Money?
        public let tax: Money?
        public let status: Status
        public let utr: String?
        public let initiatedAt: Date?
        public let processedAt: Date?
        public let reversedAt: Date?
        public let createdAt: Date?

        enum CodingKeys: String, CodingKey {
            case id, amount, currency, fees, tax, status, utr
            case initiatedAt = "initiated_at", processedAt = "processed_at", reversedAt = "reversed_at", createdAt = "created_at"
        }

        public init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            let currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
            id = try c.decode(String.self, forKey: .id)
            amount = try c.decodeMoney(.amount, currency: currency)
            fees = try c.decodeMoneyIfPresent(.fees, currency: currency)
            tax = try c.decodeMoneyIfPresent(.tax, currency: currency)
            status = try c.decode(Status.self, forKey: .status)
            utr = try c.decodeIfPresent(String.self, forKey: .utr)
            initiatedAt = try c.decodeIfPresent(Date.self, forKey: .initiatedAt)
            processedAt = try c.decodeIfPresent(Date.self, forKey: .processedAt)
            reversedAt = try c.decodeIfPresent(Date.self, forKey: .reversedAt)
            createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt)
        }
    }

    /// The body for `settlements.createInstant(_:options:)`.
    public struct Create: Sendable, Hashable, Encodable {
        /// How much to settle. Ignored when `settleFullBalance` is `true`.
        public var amount: Money?
        public var settleFullBalance: Bool
        public var description: String?
        public var notes: Notes

        /// Settles a specific amount.
        public init(amount: Money, description: String? = nil, notes: Notes = [:]) {
            self.amount = amount
            self.settleFullBalance = false
            self.description = description
            self.notes = notes
        }

        /// Settles the full available balance.
        public static func fullBalance(description: String? = nil, notes: Notes = [:]) -> Self {
            var create = Self(amount: .inr(paise: 0), description: description, notes: notes)
            create.amount = nil
            create.settleFullBalance = true
            return create
        }

        enum CodingKeys: String, CodingKey { case amount, settleFullBalance = "settle_full_balance", description, notes }
        public func encode(to encoder: any Encoder) throws {
            if !settleFullBalance, (amount?.amount ?? 0) <= 0 {
                throw EncodingError.invalidValue(amount as Any, .init(codingPath: [CodingKeys.amount], debugDescription: "settlement amount must be positive"))
            }
            var c = encoder.container(keyedBy: CodingKeys.self)
            if !settleFullBalance { try c.encodeIfPresent(amount?.amount, forKey: .amount) }
            try c.encode(settleFullBalance, forKey: .settleFullBalance)
            try c.encodeIfPresent(description, forKey: .description)
            if !notes.isEmpty { try c.encode(notes, forKey: .notes) }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, currency, fees, tax, status, description, notes
        case amountRequested = "amount_requested", amountSettled = "amount_settled", amountPending = "amount_pending"
        case amountReversed = "amount_reversed", settleFullBalance = "settle_full_balance", payouts = "ondemand_payouts"
        case createdAt = "created_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
        id = try c.decode(ID.self, forKey: .id)
        amountRequested = try c.decodeMoney(.amountRequested, currency: currency)
        amountSettled = try c.decodeMoneyIfPresent(.amountSettled, currency: currency)
        amountPending = try c.decodeMoneyIfPresent(.amountPending, currency: currency)
        amountReversed = try c.decodeMoneyIfPresent(.amountReversed, currency: currency)
        fees = try c.decodeMoneyIfPresent(.fees, currency: currency)
        tax = try c.decodeMoneyIfPresent(.tax, currency: currency)
        settleFullBalance = try c.decodeIfPresent(Bool.self, forKey: .settleFullBalance) ?? false
        status = try c.decode(Status.self, forKey: .status)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        notes = try NotesCoding.decode(c, .notes)
        // Expanded responses wrap payouts in a collection; tolerate both shapes and absence.
        if let collection = try? c.decodeIfPresent(RazorpayCollection<Payout>.self, forKey: .payouts) {
            payouts = collection.items
        } else {
            payouts = (try? c.decodeIfPresent([Payout].self, forKey: .payouts)) ?? []
        }
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}

/// One line of the settlement reconciliation report: a payment, refund, transfer, adjustment or
/// other entity that was settled. See https://razorpay.com/docs/api/settlements/fetch-recon/.
public struct SettlementReconEntry: Sendable, Hashable, Decodable {
    /// The ID of the settled entity (`pay_…`, `rfnd_…`, `trf_…`, `adj_…`).
    public let entityID: String
    public let type: EntityType
    public let amount: Money
    public let debit: Money
    public let credit: Money
    public let fee: Money?
    public let tax: Money?
    public let onHold: Bool
    public let settled: Bool
    public let settlementID: SettlementID?
    public let settlementUTR: String?
    public let paymentID: PaymentID?
    public let orderID: OrderID?
    public let orderReceipt: String?
    public let disputeID: String?
    public let method: String?
    public let cardNetwork: String?
    public let cardIssuer: String?
    public let cardType: String?
    public let creditType: String?
    public let description: String?
    /// Razorpay sends notes here as an object, a JSON-encoded string or `null`; all are accepted.
    public let notes: Notes
    public let createdAt: Date?
    public let settledAt: Date?
    public let postedAt: Date?

    public struct EntityType: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let payment: Self = "payment"
        public static let refund: Self = "refund"
        public static let transfer: Self = "transfer"
        public static let adjustment: Self = "adjustment"
        public static let dispute: Self = "dispute"
        public static let settlement: Self = "settlement"
    }

    enum CodingKeys: String, CodingKey {
        case type, amount, currency, debit, credit, fee, tax, settled, method, description, notes
        case entityID = "entity_id", onHold = "on_hold", settlementID = "settlement_id", settlementUTR = "settlement_utr"
        case paymentID = "payment_id", orderID = "order_id", orderReceipt = "order_receipt", disputeID = "dispute_id"
        case cardNetwork = "card_network", cardIssuer = "card_issuer", cardType = "card_type", creditType = "credit_type"
        case createdAt = "created_at", settledAt = "settled_at", postedAt = "posted_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let currency = try c.decodeIfPresent(Currency.self, forKey: .currency) ?? .inr
        entityID = try c.decode(String.self, forKey: .entityID)
        type = try c.decode(EntityType.self, forKey: .type)
        amount = try c.decodeMoney(.amount, currency: currency)
        debit = try c.decodeMoneyIfPresent(.debit, currency: currency) ?? Money(amount: 0, currency: currency)
        credit = try c.decodeMoneyIfPresent(.credit, currency: currency) ?? Money(amount: 0, currency: currency)
        fee = try c.decodeMoneyIfPresent(.fee, currency: currency)
        tax = try c.decodeMoneyIfPresent(.tax, currency: currency)
        onHold = try c.decodeIfPresent(Bool.self, forKey: .onHold) ?? false
        settled = try c.decodeIfPresent(Bool.self, forKey: .settled) ?? false
        settlementID = try c.decodeIfPresent(SettlementID.self, forKey: .settlementID)
        settlementUTR = try c.decodeIfPresent(String.self, forKey: .settlementUTR)
        paymentID = try c.decodeIfPresent(PaymentID.self, forKey: .paymentID)
        orderID = try c.decodeIfPresent(OrderID.self, forKey: .orderID)
        orderReceipt = try c.decodeIfPresent(String.self, forKey: .orderReceipt)
        disputeID = try c.decodeIfPresent(String.self, forKey: .disputeID)
        method = try c.decodeIfPresent(String.self, forKey: .method)
        cardNetwork = try c.decodeIfPresent(String.self, forKey: .cardNetwork)
        cardIssuer = try c.decodeIfPresent(String.self, forKey: .cardIssuer)
        cardType = try c.decodeIfPresent(String.self, forKey: .cardType)
        creditType = try c.decodeIfPresent(String.self, forKey: .creditType)
        description = try c.decodeIfPresent(String.self, forKey: .description)
        if let text = try? c.decodeIfPresent(String.self, forKey: .notes) {
            let object = (try? RazorpayCoding.decoder.decode([String: JSONValue].self, from: Data(text.utf8))) ?? [:]
            notes = object.compactMapValues { $0.stringValue ?? $0.intValue.map(String.init) }
        } else {
            notes = (try? NotesCoding.decode(c, .notes)) ?? [:]
        }
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt)
        settledAt = try c.decodeIfPresent(Date.self, forKey: .settledAt)
        postedAt = try c.decodeIfPresent(Date.self, forKey: .postedAt)
    }
}
