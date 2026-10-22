import Foundation
import RazorpayCore

/// A payment-method downtime reported by Razorpay: a bank, card network, issuer or UPI app that
/// is (or will be) failing. Poll `payments.downtimes(options:)` or listen for the
/// `payment.downtime.*` webhooks to hide affected methods at checkout.
/// See https://razorpay.com/docs/api/payments/downtime/.
public struct Downtime: Sendable, Hashable, Identifiable, Codable {
    public typealias ID = DowntimeID

    public let id: ID
    public let method: Method
    /// When the downtime started, or is scheduled to start.
    public let begin: Date
    /// When it ended or is expected to end. `nil` means Razorpay doesn't know yet.
    public let end: Date?
    public let status: Status
    /// `true` for planned maintenance announced ahead of time.
    public let scheduled: Bool
    public let severity: Severity
    /// What is affected: a bank, card network or issuer, or a UPI handle or app.
    public let instrument: Instrument
    /// Absent in some webhook samples.
    public let createdAt: Date?
    public let updatedAt: Date?

    public init(id: ID, method: Method, begin: Date, end: Date? = nil, status: Status, scheduled: Bool = false,
                severity: Severity, instrument: Instrument = .init(), createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id; self.method = method; self.begin = begin; self.end = end; self.status = status
        self.scheduled = scheduled; self.severity = severity; self.instrument = instrument
        self.createdAt = createdAt; self.updatedAt = updatedAt
    }

    /// `true` while payments through ``instrument`` are expected to fail.
    public var isOngoing: Bool { status == .started || status == .updated }

    public struct Method: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let card: Self = "card"
        public static let netbanking: Self = "netbanking"
        public static let upi: Self = "upi"
    }

    /// Razorpay's docs use both `updated` and `started` for an ongoing downtime; treat both as ongoing.
    public struct Status: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let scheduled: Self = "scheduled"
        public static let started: Self = "started"
        public static let updated: Self = "updated"
        public static let resolved: Self = "resolved"
        public static let cancelled: Self = "cancelled"
    }

    public struct Severity: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        public static let high: Self = "high"
        public static let medium: Self = "medium"
        public static let low: Self = "low"
    }

    /// The affected instrument. Each field is set only for the methods it applies to; `"ALL"` means
    /// every network or handle (see ``isAll``).
    public struct Instrument: Sendable, Hashable, Codable {
        /// Netbanking bank code, for example `HDFC`.
        public var bank: String?
        /// Card issuer code, for example `SBIN`.
        public var issuer: String?
        public var network: Network?
        /// `credit`, `debit` or `prepaid`. The API calls it `card_type`; webhooks call it `type`.
        public var cardType: String?
        /// UPI app, for example `google_pay`.
        public var psp: String?
        /// UPI handle, for example `okhdfcbank`.
        public var vpaHandle: String?
        public var flow: Flow?
        /// Any other keys Razorpay sends.
        public var other: [String: JSONValue]

        public init(bank: String? = nil, issuer: String? = nil, network: Network? = nil, cardType: String? = nil,
                    psp: String? = nil, vpaHandle: String? = nil, flow: Flow? = nil, other: [String: JSONValue] = [:]) {
            self.bank = bank; self.issuer = issuer; self.network = network; self.cardType = cardType
            self.psp = psp; self.vpaHandle = vpaHandle; self.flow = flow; self.other = other
        }

        /// `true` when the downtime covers every network or every UPI handle.
        public var isAll: Bool { network == .all || vpaHandle == "ALL" }

        public struct Network: RazorpayStringEnum {
            public let rawValue: String
            public init(rawValue: String) { self.rawValue = rawValue }
            public static let amex: Self = "AMEX"
            public static let dinersClub: Self = "DICL"
            public static let mastercard: Self = "MC"
            public static let rupay: Self = "RUPAY"
            public static let visa: Self = "VISA"
            public static let all: Self = "ALL"
        }

        /// The UPI flow affected.
        public struct Flow: RazorpayStringEnum {
            public let rawValue: String
            public init(rawValue: String) { self.rawValue = rawValue }
            public static let collect: Self = "collect"
            public static let intent: Self = "intent"
            /// Turbo UPI.
            public static let inApp: Self = "in_app"
        }

        private static let known: Set<String> = ["bank", "issuer", "network", "card_type", "type", "psp", "vpa_handle", "flow"]

        public init(from decoder: any Decoder) throws {
            let c = try decoder.container(keyedBy: AnyCodingKey.self)
            func s(_ k: String) throws -> String? { try c.decodeIfPresent(String.self, forKey: AnyCodingKey(k)) }
            bank = try s("bank"); issuer = try s("issuer"); psp = try s("psp"); vpaHandle = try s("vpa_handle")
            cardType = try s("card_type") ?? s("type")
            network = try c.decodeIfPresent(Network.self, forKey: AnyCodingKey("network"))
            flow = try c.decodeIfPresent(Flow.self, forKey: AnyCodingKey("flow"))
            var other: [String: JSONValue] = [:]
            for key in c.allKeys where !Self.known.contains(key.stringValue) {
                other[key.stringValue] = try c.decode(JSONValue.self, forKey: key)
            }
            self.other = other
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: AnyCodingKey.self)
            for (key, value) in other where !Self.known.contains(key) { try c.encode(value, forKey: AnyCodingKey(key)) }
            try c.encodeIfPresent(bank, forKey: AnyCodingKey("bank"))
            try c.encodeIfPresent(issuer, forKey: AnyCodingKey("issuer"))
            try c.encodeIfPresent(network, forKey: AnyCodingKey("network"))
            try c.encodeIfPresent(cardType, forKey: AnyCodingKey("card_type"))
            try c.encodeIfPresent(psp, forKey: AnyCodingKey("psp"))
            try c.encodeIfPresent(vpaHandle, forKey: AnyCodingKey("vpa_handle"))
            try c.encodeIfPresent(flow, forKey: AnyCodingKey("flow"))
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, method, begin, end, status, scheduled, severity, instrument
        case createdAt = "created_at", updatedAt = "updated_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        method = try c.decode(Method.self, forKey: .method)
        begin = try c.decode(Date.self, forKey: .begin)
        end = try c.decodeIfPresent(Date.self, forKey: .end)
        status = try c.decode(Status.self, forKey: .status)
        scheduled = try c.decodeFlagIfPresent(.scheduled) ?? false
        severity = try c.decode(Severity.self, forKey: .severity)
        instrument = try c.decodeIfPresent(Instrument.self, forKey: .instrument) ?? .init()
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
}

extension Downtime: WebhookEntity { public static var payloadKey: String { "payment.downtime" } }

extension RazorpayWebhook.Name {
    public static let downtimeStarted: Self = "payment.downtime.started"
    public static let downtimeUpdated: Self = "payment.downtime.updated"
    public static let downtimeResolved: Self = "payment.downtime.resolved"
}
