import Foundation

/// A model that can appear in a webhook payload, under ``payloadKey``
/// (for example `"payment"` or `"payment.downtime"`).
public protocol WebhookEntity: Decodable, Sendable {
    static var payloadKey: String { get }
}

/// A verified webhook envelope: `{"event": …, "payload": {key: {"entity": {…}}}, …}`.
///
/// Every module can read it, so typed decoding works whichever modules you import:
///
/// ```swift
/// let webhook = try razorpay.webhooks.verify(body, signature: header)
/// if webhook.name == .paymentCaptured {
///     let payment = try webhook.entity(Payment.self)
/// }
/// ```
/// With `import RazorpayKit`, `try webhook.event` gives an exhaustive `WebhookEvent` enum.
public struct RazorpayWebhook: Sendable, Hashable, Decodable {
    /// An event name such as `payment.captured`. Open: unknown names are kept.
    public struct Name: RazorpayStringEnum {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
    }

    public let name: Name
    public let accountID: String?
    /// The entity keys present in ``payload``, for example `["payment", "order"]`.
    public let contains: [String]
    /// The raw `payload` object.
    public let payload: JSONValue
    public let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case name = "event", accountID = "account_id", contains, payload, createdAt = "created_at"
    }

    public init(name: Name, accountID: String? = nil, contains: [String] = [], payload: JSONValue = [:], createdAt: Date? = nil) {
        self.name = name
        self.accountID = accountID
        self.contains = contains
        self.payload = payload
        self.createdAt = createdAt
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(Name.self, forKey: .name)
        accountID = try c.decodeIfPresent(String.self, forKey: .accountID)
        contains = (try? c.decodeIfPresent([String].self, forKey: .contains)) ?? []
        payload = try c.decodeIfPresent(JSONValue.self, forKey: .payload) ?? [:]
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt)
    }

    /// Decodes raw (already verified) body bytes.
    package static func decode(_ body: [UInt8]) -> Result<RazorpayWebhook, RazorpayError> {
        do {
            return .success(try RazorpayCoding.decoder.decode(RazorpayWebhook.self, from: Data(body)))
        } catch {
            return .failure(.decoding(.init(error, type: RazorpayWebhook.self, statusCode: nil)))
        }
    }

    /// `true` when `payload[T.payloadKey].entity` is present.
    public func has<T: WebhookEntity>(_ type: T.Type) -> Bool { payload[T.payloadKey]?["entity"] != nil }

    package func entityResult<T: WebhookEntity>(_ type: T.Type) -> Result<T, RazorpayError> {
        guard let value = payload[T.payloadKey]?["entity"] else {
            return .failure(.decoding(.init(type: String(describing: T.self), path: "payload.\(T.payloadKey).entity", message: "missing required field")))
        }
        do { return .success(try value.decode(as: T.self)) } catch {
            return .failure(.decoding(.init(error, type: T.self, statusCode: nil)))
        }
    }

    #if compiler(>=6.0)
    /// Decodes `payload[T.payloadKey].entity`, for example `try webhook.entity(Payment.self)`.
    public func entity<T: WebhookEntity>(_ type: T.Type) throws(RazorpayError) -> T { try entityResult(type).get() }
    #else
    /// Decodes `payload[T.payloadKey].entity`, for example `try webhook.entity(Payment.self)`.
    public func entity<T: WebhookEntity>(_ type: T.Type) throws -> T { try entityResult(type).get() }
    #endif
}
