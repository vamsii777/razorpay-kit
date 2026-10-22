import Foundation
import RazorpayCore
import RazorpayPayments

extension RazorpayClient {
    /// Cards: fetch a card and look up a card's network reference. See https://razorpay.com/docs/api/payments/cards/.
    public var cards: Cards { Cards(handler: handler) }

    /// Cards: fetch a card and look up a card's network reference.
    public struct Cards: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}

/// A card's network-level identity (`POST /v1/cards/fingerprints`): the same card gets the same reference
/// across merchants and tokens.
public struct CardReference: Sendable, Hashable, Codable {
    public let network: Card.Network?
    /// Payment Account Reference, stable for the card across tokens.
    public let paymentAccountReference: String?
    public let networkReferenceID: String?

    public init(network: Card.Network? = nil, paymentAccountReference: String? = nil, networkReferenceID: String? = nil) {
        self.network = network; self.paymentAccountReference = paymentAccountReference; self.networkReferenceID = networkReferenceID
    }

    enum CodingKeys: String, CodingKey {
        case network, paymentAccountReference = "payment_account_reference", networkReferenceID = "network_reference_id"
    }
}

/// The body of a card-reference request: the card number, or a token. Never log it.
public enum CardReferenceRequest: Sendable, Hashable, Encodable {
    case number(String)
    case token(String)

    enum CodingKeys: String, CodingKey { case number, tokenised, token }

    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .number(let n): try c.encode(n.filter(\.isNumber), forKey: .number)
        case .token(let t): try c.encode(t, forKey: .number); try c.encode(true, forKey: .tokenised)
        }
    }

    var isEmpty: Bool {
        switch self {
        case .number(let n): return n.filter(\.isNumber).isEmpty
        case .token(let t): return t.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
}
