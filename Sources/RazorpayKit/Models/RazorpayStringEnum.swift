import Foundation

/// A string-backed value set that stays open: values this SDK does not know yet decode
/// instead of failing, and are kept in ``rawValue``.
///
/// Conforming types declare known values as `static let`s, which you can match in a `switch`:
///
/// ```swift
/// switch payment.status {
/// case .captured: ship()
/// case .failed:   retry()
/// default:        log("new status \(payment.status)")
/// }
/// ```
public protocol RazorpayStringEnum: RawRepresentable, Hashable, Sendable, Codable,
    CustomStringConvertible, ExpressibleByStringLiteral where RawValue == String {
    init(rawValue: String)
}

extension RazorpayStringEnum {
    public init(stringLiteral value: String) { self.init(rawValue: value) }
    public init(from decoder: any Decoder) throws {
        self.init(rawValue: try decoder.singleValueContainer().decode(String.self))
    }
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    public var description: String { rawValue }
}
