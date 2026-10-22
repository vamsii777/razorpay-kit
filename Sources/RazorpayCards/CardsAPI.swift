import Foundation
import RazorpayCore
import RazorpayPayments

#if compiler(>=6.0)
extension RazorpayClient.Cards {
    /// Fetches a card by ID.
    public func fetch(_ id: Card.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Card {
        try await handler.perform(.GET, "/v1/cards/\(id.pathComponent().get())", options: options)
    }

    /// Looks up a card's network reference (PAR) from its number or a token.
    public func reference(_ request: CardReferenceRequest, options: RequestOptions = .init()) async throws(RazorpayError) -> CardReference {
        guard !request.isEmpty else { throw RazorpayError.invalidRequest("card number or token is empty") }
        return try await handler.perform(.POST, "/v1/cards/fingerprints", body: request, options: options)
    }
}
#else
extension RazorpayClient.Cards {
    /// Fetches a card by ID.
    public func fetch(_ id: Card.ID, options: RequestOptions = .init()) async throws -> Card {
        try await handler.perform(.GET, "/v1/cards/\(id.pathComponent().get())", options: options)
    }

    /// Looks up a card's network reference (PAR) from its number or a token.
    public func reference(_ request: CardReferenceRequest, options: RequestOptions = .init()) async throws -> CardReference {
        guard !request.isEmpty else { throw RazorpayError.invalidRequest("card number or token is empty") }
        return try await handler.perform(.POST, "/v1/cards/fingerprints", body: request, options: options)
    }
}
#endif
