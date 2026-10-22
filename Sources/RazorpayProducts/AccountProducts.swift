import Foundation
import NIOHTTP1
import RazorpayCore

extension RazorpayClient {
    /// Product configurations on partner sub-merchant accounts.
    /// See https://razorpay.com/docs/api/partners/product-configuration/.
    public var accountProducts: AccountProducts { AccountProducts(handler: handler) }

    /// Product configurations on partner sub-merchant accounts.
    /// See https://razorpay.com/docs/api/partners/product-configuration/.
    public struct AccountProducts: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
#if compiler(>=6.0)
extension RazorpayClient.AccountProducts {
        /// Requests a product for an account.
        public func request(_ request: AccountProduct.Request, for account: AccountID, options: RequestOptions = .init()) async throws(RazorpayError) -> AccountProduct {
            try await handler.perform(.POST, "/v2/accounts/\(account.pathComponent().get())/products", body: request, options: options)
        }

        /// Fetches a product configuration.
        public func fetch(_ id: AccountProduct.ID, account: AccountID, options: RequestOptions = .init()) async throws(RazorpayError) -> AccountProduct {
            try await handler.perform(.GET, "/v2/accounts/\(account.pathComponent().get())/products/\(id.pathComponent().get())", options: options)
        }

        /// Updates a product configuration. The body's shape depends on the product
        /// (for example `["settlements": ["account_number": "…", "ifsc_code": "…", "beneficiary_name": "…"]]`).
        public func update(_ id: AccountProduct.ID, account: AccountID, _ changes: JSONValue, options: RequestOptions = .init()) async throws(RazorpayError) -> AccountProduct {
            try await handler.perform(.PATCH, "/v2/accounts/\(account.pathComponent().get())/products/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Fetches the current terms and conditions for a product.
        public func terms(for product: AccountProduct.ProductName, options: RequestOptions = .init()) async throws(RazorpayError) -> ProductTerms {
            try await handler.perform(.GET, "/v2/products/\(RZPRUTL.percentEncode(product.rawValue))/tnc", options: options)
        }
}
#else
extension RazorpayClient.AccountProducts {
        /// Requests a product for an account.
        public func request(_ request: AccountProduct.Request, for account: AccountID, options: RequestOptions = .init()) async throws -> AccountProduct {
            try await handler.perform(.POST, "/v2/accounts/\(account.pathComponent().get())/products", body: request, options: options)
        }

        /// Fetches a product configuration.
        public func fetch(_ id: AccountProduct.ID, account: AccountID, options: RequestOptions = .init()) async throws -> AccountProduct {
            try await handler.perform(.GET, "/v2/accounts/\(account.pathComponent().get())/products/\(id.pathComponent().get())", options: options)
        }

        /// Updates a product configuration. The body's shape depends on the product
        /// (for example `["settlements": ["account_number": "…", "ifsc_code": "…", "beneficiary_name": "…"]]`).
        public func update(_ id: AccountProduct.ID, account: AccountID, _ changes: JSONValue, options: RequestOptions = .init()) async throws -> AccountProduct {
            try await handler.perform(.PATCH, "/v2/accounts/\(account.pathComponent().get())/products/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Fetches the current terms and conditions for a product.
        public func terms(for product: AccountProduct.ProductName, options: RequestOptions = .init()) async throws -> ProductTerms {
            try await handler.perform(.GET, "/v2/products/\(RZPRUTL.percentEncode(product.rawValue))/tnc", options: options)
        }
}
#endif
