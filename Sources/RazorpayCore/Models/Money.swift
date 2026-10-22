import Foundation

/// An amount in the currency's smallest unit (paise for INR), plus its currency.
///
/// Razorpay always works in minor units. `Money` keeps them together so an amount can never lose
/// its currency:
///
/// ```swift
/// let price: Money = .inr(paise: 49_900)   // ₹499.00
/// let same = Money.inr(rupees: 499)
/// price.decimalAmount                      // 499
/// ```
public struct Money: Hashable, Sendable, Codable, Comparable, CustomStringConvertible {
    /// The amount in minor units, for example `49900` for ₹499.00.
    public var amount: Int
    /// The currency.
    public var currency: Currency

    public init(amount: Int, currency: Currency) {
        self.amount = amount
        self.currency = currency
    }

    /// Creates an amount from a major-unit decimal, rounding half-up to the currency's exponent.
    public init(_ major: Decimal, currency: Currency) {
        self.init(amount: currency.convertToSmallestUnit(major), currency: currency)
    }

    /// An INR amount in paise.
    public static func inr(paise: Int) -> Money { Money(amount: paise, currency: .inr) }
    /// An INR amount in rupees, for example `499.5`.
    public static func inr(rupees: Decimal) -> Money { Money(rupees, currency: .inr) }

    /// The amount in major units, for example `499.00`.
    public var decimalAmount: Decimal { currency.convertFromSmallestUnit(amount) }

    /// `₹499.00`-style text. Uses a fixed format so output does not depend on the locale.
    public var description: String {
        let digits = currency.exponent
        let sign = amount < 0 ? "-" : ""
        let magnitude = amount.magnitude
        guard digits > 0 else { return "\(sign)\(currency.symbol)\(magnitude)" }
        let divisor = UInt(pow(10, Double(digits)))
        let fraction = String(magnitude % divisor)
        return "\(sign)\(currency.symbol)\(magnitude / divisor).\(String(repeating: "0", count: digits - fraction.count))\(fraction)"
    }

    /// Orders amounts in the same currency. Amounts in different currencies compare by code first.
    public static func < (lhs: Money, rhs: Money) -> Bool {
        lhs.currency == rhs.currency ? lhs.amount < rhs.amount : lhs.currency.rawValue < rhs.currency.rawValue
    }
}

extension KeyedDecodingContainer {
    /// Decodes Razorpay's flat `amount` + `currency` pair into ``Money``.
    package func decodeMoney(_ amountKey: Key, currency: Currency) throws -> Money {
        Money(amount: try decode(Int.self, forKey: amountKey), currency: currency)
    }

    package func decodeMoneyIfPresent(_ amountKey: Key, currency: Currency) throws -> Money? {
        try decodeIfPresent(Int.self, forKey: amountKey).map { Money(amount: $0, currency: currency) }
    }
}
