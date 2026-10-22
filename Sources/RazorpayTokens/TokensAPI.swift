import Foundation
import RazorpayCore

#if compiler(>=6.0)
extension RazorpayClient.Tokens {
    /// Lists a customer's saved tokens. The endpoint isn't paginated.
    public func list(for customer: CustomerID, options: RequestOptions = .init()) async throws(RazorpayError) -> [Token] {
        let page: RazorpayCollection<Token> = try await handler.perform(.GET, "/v1/customers/\(customer.pathComponent().get())/tokens", options: options)
        return page.items
    }

    /// Fetches one of a customer's tokens.
    public func fetch(_ id: Token.ID, for customer: CustomerID, options: RequestOptions = .init()) async throws(RazorpayError) -> Token {
        try await handler.perform(.GET, "/v1/customers/\(customer.pathComponent().get())/tokens/\(id.pathComponent().get())", options: options)
    }

    /// Deletes a customer's token. Recurring payments on it stop working.
    @discardableResult
    public func delete(_ id: Token.ID, for customer: CustomerID, options: RequestOptions = .init()) async throws(RazorpayError) -> DeletionResult {
        try await handler.perform(.DELETE, "/v1/customers/\(customer.pathComponent().get())/tokens/\(id.pathComponent().get())", options: options)
    }
}
#else
extension RazorpayClient.Tokens {
    /// Lists a customer's saved tokens. The endpoint isn't paginated.
    public func list(for customer: CustomerID, options: RequestOptions = .init()) async throws -> [Token] {
        let page: RazorpayCollection<Token> = try await handler.perform(.GET, "/v1/customers/\(customer.pathComponent().get())/tokens", options: options)
        return page.items
    }

    /// Fetches one of a customer's tokens.
    public func fetch(_ id: Token.ID, for customer: CustomerID, options: RequestOptions = .init()) async throws -> Token {
        try await handler.perform(.GET, "/v1/customers/\(customer.pathComponent().get())/tokens/\(id.pathComponent().get())", options: options)
    }

    /// Deletes a customer's token. Recurring payments on it stop working.
    @discardableResult
    public func delete(_ id: Token.ID, for customer: CustomerID, options: RequestOptions = .init()) async throws -> DeletionResult {
        try await handler.perform(.DELETE, "/v1/customers/\(customer.pathComponent().get())/tokens/\(id.pathComponent().get())", options: options)
    }
}
#endif
