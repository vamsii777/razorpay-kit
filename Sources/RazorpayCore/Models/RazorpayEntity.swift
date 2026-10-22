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
