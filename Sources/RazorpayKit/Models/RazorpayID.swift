import Foundation

/// A strongly typed Razorpay identifier, such as `Payment.ID` (`pay_…`) or `Order.ID` (`order_…`).
///
/// The phantom `Entity` stops you passing an order ID where a payment ID is expected, while string
/// literals still work:
///
/// ```swift
/// let payment = try await razorpay.payments.fetch("pay_29QQoUBi66xm2f")
/// ```
public struct RazorpayID<Entity>: RawRepresentable, Hashable, Sendable, Codable,
    ExpressibleByStringLiteral, CustomStringConvertible, Comparable {
    /// The identifier exactly as Razorpay sent it.
    public let rawValue: String

    public init(rawValue: String) { self.rawValue = rawValue }
    public init(_ rawValue: String) { self.rawValue = rawValue }
    public init(stringLiteral value: String) { self.rawValue = value }

    public init(from decoder: any Decoder) throws {
        rawValue = try decoder.singleValueContainer().decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public var description: String { rawValue }

    public static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    /// The ID as a single, percent-encoded path segment. Throws for empty IDs and IDs containing `/`.
    func pathComponent() -> Result<String, RazorpayError> {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .failure(.invalidRequest("\(Entity.self) ID is empty")) }
        guard !trimmed.contains("/") else { return .failure(.invalidRequest("\(Entity.self) ID contains '/'")) }
        return .success(RZPRUTL.percentEncode(trimmed))
    }
}
