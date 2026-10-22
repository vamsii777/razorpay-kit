import Foundation
import RazorpayCore

/// A webhook URL registered on your account or a sub-merchant's account.
/// See https://razorpay.com/docs/api/partners/webhooks/.
public struct WebhookEndpoint: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = WebhookEndpointID

    public let id: ID
    public let url: String
    public let alertEmail: String?
    public let active: Bool
    /// Whether a signing secret is set. The secret itself is never returned.
    public let secretExists: Bool
    public let events: [RazorpayWebhook.Name]
    public let ownerID: String?
    public let ownerType: String?
    public let disabledAt: Date?
    public let createdAt: Date?
    public let updatedAt: Date?

    /// The body for ``RazorpayClient/WebhookEndpoints/create(_:account:options:)``.
    ///
    /// The `secret` is sent to Razorpay and never logged: this type redacts it in `description` and mirrors.
    public struct Create: Sendable, Hashable, Encodable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
        public var url: String
        public var events: [RazorpayWebhook.Name]
        public var alertEmail: String?
        public var secret: String?

        public init(url: String, events: [RazorpayWebhook.Name], alertEmail: String? = nil, secret: String? = nil) {
            self.url = url
            self.events = events
            self.alertEmail = alertEmail
            self.secret = secret
        }

        enum CodingKeys: String, CodingKey { case url, events, alertEmail = "alert_email", secret }
        public func encode(to encoder: any Encoder) throws {
            guard url.lowercased().hasPrefix("https://") else {
                throw EncodingError.invalidValue(url, .init(codingPath: [CodingKeys.url], debugDescription: "webhook URL must use https"))
            }
            guard !events.isEmpty else {
                throw EncodingError.invalidValue(events, .init(codingPath: [CodingKeys.events], debugDescription: "subscribe to at least one event"))
            }
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(url, forKey: .url)
            try c.encode(events, forKey: .events)
            try c.encodeIfPresent(alertEmail, forKey: .alertEmail)
            try c.encodeIfPresent(secret, forKey: .secret)
        }

        public var description: String { "WebhookEndpoint.Create(url: \(url), events: \(events.count), secret: \(secret == nil ? "nil" : "<redacted>"))" }
        public var debugDescription: String { description }
        public var customMirror: Mirror {
            Mirror(self, children: ["url": url, "events": events, "alertEmail": alertEmail as Any, "secret": secret == nil ? "nil" : "<redacted>"], displayStyle: .struct)
        }
    }

    /// Changes for ``RazorpayClient/WebhookEndpoints/update(_:account:_:options:)``. Razorpay requires `url` and `events`.
    public typealias Update = Create

    enum CodingKeys: String, CodingKey {
        case id, url, active, events
        case alertEmail = "alert_email", secretExists = "secret_exists", ownerID = "owner_id", ownerType = "owner_type"
        case disabledAt = "disabled_at", createdAt = "created_at", updatedAt = "updated_at"
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        url = try c.decode(String.self, forKey: .url)
        alertEmail = try c.decodeIfPresent(String.self, forKey: .alertEmail)
        active = try c.decodeIfPresent(Bool.self, forKey: .active) ?? true
        secretExists = try c.decodeIfPresent(Bool.self, forKey: .secretExists) ?? false
        // v2 returns a list of names; v1 returns {"payment.captured": true, …}.
        if let names = try? c.decodeIfPresent([RazorpayWebhook.Name].self, forKey: .events) {
            events = names
        } else if let map = try? c.decodeIfPresent([String: Bool].self, forKey: .events) {
            events = map.filter(\.value).keys.sorted().map { RazorpayWebhook.Name(rawValue: $0) }
        } else {
            events = []
        }
        ownerID = try c.decodeIfPresent(String.self, forKey: .ownerID)
        ownerType = try c.decodeIfPresent(String.self, forKey: .ownerType)
        // `disabled_at` is 0 while enabled.
        disabledAt = try c.decodeIfPresent(Int.self, forKey: .disabledAt).flatMap { $0 > 0 ? Date(timeIntervalSince1970: TimeInterval($0)) : nil }
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt)
    }
}
