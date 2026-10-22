/// Phantom tags for ``RazorpayID``. They live in Core so modules can reference each other's IDs
/// (for example `Payment.orderID`) without importing each other, which keeps the module graph acyclic.
public enum RazorpayEntity {
    public enum Payment {}
    public enum Order {}
    public enum Refund {}
    public enum Customer {}
    public enum Downtime {}
}

public typealias PaymentID = RazorpayID<RazorpayEntity.Payment>
public typealias OrderID = RazorpayID<RazorpayEntity.Order>
public typealias RefundID = RazorpayID<RazorpayEntity.Refund>
public typealias CustomerID = RazorpayID<RazorpayEntity.Customer>
public typealias DowntimeID = RazorpayID<RazorpayEntity.Downtime>

/// `{"notes": {...}}`, the body of every notes-only update.
package struct NotesBody: Encodable, Sendable {
    package let notes: Notes
    package init(notes: Notes) { self.notes = notes }
}

extension RazorpayEntity {
    public enum Card {}
}

public typealias CardID = RazorpayID<RazorpayEntity.Card>

/// A coding key for arbitrary JSON object keys, for models that keep unmodelled fields.
package struct AnyCodingKey: CodingKey, Hashable, Sendable {
    package let stringValue: String
    package var intValue: Int? { nil }
    package init(_ string: String) { stringValue = string }
    package init?(stringValue: String) { self.stringValue = stringValue }
    package init?(intValue: Int) { stringValue = String(intValue) }
}

extension KeyedDecodingContainer {
    /// Decodes a flag Razorpay sends as `true`/`false` or `1`/`0`. Missing or `null` is `nil`.
    package func decodeFlagIfPresent(_ key: Key) throws -> Bool? {
        guard contains(key), try !decodeNil(forKey: key) else { return nil }
        if let bool = try? decode(Bool.self, forKey: key) { return bool }
        return try decode(Int.self, forKey: key) != 0
    }
}
