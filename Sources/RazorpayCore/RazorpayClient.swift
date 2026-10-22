import NIO
import AsyncHTTPClient

/// The entry point to the Razorpay API.
///
/// `RazorpayClient` holds only credentials and a transport. Each `Razorpay*` module you import
/// adds its namespace to it, for example `razorpay.payments` from RazorpayPayments or
/// `razorpay.orders` from RazorpayOrders. `import RazorpayKit` brings in all of them.
///
/// ```swift
/// let razorpay = RazorpayClient(key: keyID, secret: keySecret, webhookSecret: webhookSecret)
/// ```
public struct RazorpayClient: Sendable {
    
    package let handler: RazorpayAPIHandler
    /// Secrets used only for local signature checks. Never exposed via description or mirror.
    package let signing: SigningSecrets
    
    /// Creates a new Razorpay API client.
    /// - Parameters:
    ///   - httpClient: The HTTP client to use for making requests
    ///   - key: Your Razorpay API key
    ///   - secret: Your Razorpay API secret
    ///   - webhookSecret: The secret set on your webhook in the Dashboard. Needed for
    ///     `webhooks.verify(_:signature:)`.
    public init(_ httpClient: HTTPClient = HTTPClient.shared, key: String, secret: String, webhookSecret: String? = nil) {
        self.init(transport: AsyncHTTPClientTransport(httpClient: httpClient), key: key, secret: secret, webhookSecret: webhookSecret)
    }

    /// Creates a client that sends every request through a custom transport.
    ///
    /// The base URL is always `https://api.razorpay.com`. A transport can change how requests are
    /// sent, for example a mock in tests, but it cannot change the host.
    /// - Parameters:
    ///   - transport: The transport that sends requests.
    ///   - key: Your Razorpay API key ID.
    ///   - secret: Your Razorpay API key secret.
    ///   - webhookSecret: The webhook secret from the Dashboard, used by `webhooks` (RazorpayVerification).
    public init(transport: any RazorpayTransport, key: String, secret: String, webhookSecret: String? = nil) {
        self.handler = RazorpayAPIHandler(transport: transport, key: key, secret: secret)
        self.signing = SigningSecrets(keySecret: secret, webhookSecret: webhookSecret)
    }
}

extension RazorpayClient: CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    /// A description that never includes the API key or secret.
    public var description: String { "RazorpayClient(credentials: <redacted>)" }
    /// A debug description that never includes the API key or secret.
    public var debugDescription: String { description }
    /// A mirror that hides the API key, secret and Authorization header.
    public var customMirror: Mirror {
        Mirror(self, children: ["credentials": "<redacted>"], displayStyle: .struct)
    }
}

/// Holds signing secrets and hides them from `print`, `dump` and string interpolation.
package struct SigningSecrets: Sendable, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable {
    package let keySecret: String
    package let webhookSecret: String?
    package var description: String { "SigningSecrets(<redacted>)" }
    package var debugDescription: String { description }
    package var customMirror: Mirror { Mirror(self, children: [], displayStyle: .struct) }
}
