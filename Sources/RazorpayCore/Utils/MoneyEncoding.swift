import Foundation

extension KeyedEncodingContainer {
    /// Writes `money.amount` (minor units) under `key`, the inverse of `decodeMoney`. The currency is
    /// written separately, once per object, as Razorpay expects.
    package mutating func encodeMoney(_ money: Money?, _ key: Key) throws {
        try encodeIfPresent(money?.amount, forKey: key)
    }

    /// Writes `notes` only when it isn't empty (Razorpay rejects `null` notes on some endpoints).
    package mutating func encodeNotes(_ notes: Notes, _ key: Key) throws {
        if !notes.isEmpty { try encode(notes, forKey: key) }
    }
}
