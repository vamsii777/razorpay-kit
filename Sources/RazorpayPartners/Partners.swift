import Foundation
import NIOHTTP1
import RazorpayCore

extension RazorpayClient {
    /// Partner sub-merchant accounts: create, fetch, update, delete.
    /// See https://razorpay.com/docs/api/partners/account-onboarding/.
    public var accounts: Accounts { Accounts(handler: handler) }

    /// Webhook endpoint management for your account or a sub-merchant's.
    /// See https://razorpay.com/docs/api/partners/webhooks/.
    public var webhookEndpoints: WebhookEndpoints { WebhookEndpoints(handler: handler) }

    /// Partner sub-merchant accounts: create, fetch, update, delete.
    /// See https://razorpay.com/docs/api/partners/account-onboarding/.
    public struct Accounts: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }

    /// Webhook endpoint management for your account or a sub-merchant's.
    /// See https://razorpay.com/docs/api/partners/webhooks/.
    public struct WebhookEndpoints: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}

/// `/v1/webhooks` for your own account, `/v2/accounts/{id}/webhooks` for a sub-merchant.
private func webhooksPath(_ account: AccountID?) -> Result<String, RazorpayError> {
    guard let account else { return .success("/v1/webhooks") }
    return account.pathComponent().map { "/v2/accounts/\($0)/webhooks" }
}
#if compiler(>=6.0)
extension RazorpayClient.Accounts {
        /// Creates a sub-merchant account.
        public func create(_ account: Account.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> Account {
            try await handler.perform(.POST, "/v2/accounts", body: account, options: options)
        }

        /// Fetches an account.
        public func fetch(_ id: Account.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Account {
            try await handler.perform(.GET, "/v2/accounts/\(id.pathComponent().get())", options: options)
        }

        /// Updates an account. Send only the fields to change, shaped as in the docs
        /// (for example `["customer_facing_business_name": "Acme", "profile": ["addresses": …]]`).
        public func update(_ id: Account.ID, _ changes: JSONValue, options: RequestOptions = .init()) async throws(RazorpayError) -> Account {
            try await handler.perform(.PATCH, "/v2/accounts/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Deletes (suspends) an account. Razorpay returns the account with its new status.
        public func delete(_ id: Account.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Account {
            try await handler.perform(.DELETE, "/v2/accounts/\(id.pathComponent().get())", options: options)
        }
}

extension RazorpayClient.WebhookEndpoints {
        /// Registers a webhook. Pass `account` to register it on a sub-merchant's account.
        public func create(_ webhook: WebhookEndpoint.Create, account: AccountID? = nil, options: RequestOptions = .init()) async throws(RazorpayError) -> WebhookEndpoint {
            try await handler.perform(.POST, webhooksPath(account).get(), body: webhook, options: options)
        }

        /// Fetches a sub-merchant's webhook.
        public func fetch(_ id: WebhookEndpoint.ID, account: AccountID, options: RequestOptions = .init()) async throws(RazorpayError) -> WebhookEndpoint {
            try await handler.perform(.GET, "\(webhooksPath(account).get())/\(id.pathComponent().get())", options: options)
        }

        /// Lists webhooks, fetching pages lazily. Pass `account` for a sub-merchant's webhooks.
        public func list(account: AccountID? = nil, _ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<WebhookEndpoint> {
            RazorpayList(handler: handler, path: webhooksPath(account), options: list, request: options)
        }

        /// Replaces a webhook's URL, events and alert email. Uses `PUT` on your own account and `PATCH` on a sub-merchant's.
        public func update(_ id: WebhookEndpoint.ID, account: AccountID? = nil, _ changes: WebhookEndpoint.Update, options: RequestOptions = .init()) async throws(RazorpayError) -> WebhookEndpoint {
            try await handler.perform(account == nil ? .PUT : .PATCH, "\(webhooksPath(account).get())/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Deletes a sub-merchant's webhook.
        public func delete(_ id: WebhookEndpoint.ID, account: AccountID, options: RequestOptions = .init()) async throws(RazorpayError) {
            try await handler.resultIgnoringBody(.DELETE, "\(webhooksPath(account).get())/\(id.pathComponent().get())", options: options).get()
        }
}
#else
extension RazorpayClient.Accounts {
        /// Creates a sub-merchant account.
        public func create(_ account: Account.Create, options: RequestOptions = .init()) async throws -> Account {
            try await handler.perform(.POST, "/v2/accounts", body: account, options: options)
        }

        /// Fetches an account.
        public func fetch(_ id: Account.ID, options: RequestOptions = .init()) async throws -> Account {
            try await handler.perform(.GET, "/v2/accounts/\(id.pathComponent().get())", options: options)
        }

        /// Updates an account. Send only the fields to change, shaped as in the docs
        /// (for example `["customer_facing_business_name": "Acme", "profile": ["addresses": …]]`).
        public func update(_ id: Account.ID, _ changes: JSONValue, options: RequestOptions = .init()) async throws -> Account {
            try await handler.perform(.PATCH, "/v2/accounts/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Deletes (suspends) an account. Razorpay returns the account with its new status.
        public func delete(_ id: Account.ID, options: RequestOptions = .init()) async throws -> Account {
            try await handler.perform(.DELETE, "/v2/accounts/\(id.pathComponent().get())", options: options)
        }
}

extension RazorpayClient.WebhookEndpoints {
        /// Registers a webhook. Pass `account` to register it on a sub-merchant's account.
        public func create(_ webhook: WebhookEndpoint.Create, account: AccountID? = nil, options: RequestOptions = .init()) async throws -> WebhookEndpoint {
            try await handler.perform(.POST, webhooksPath(account).get(), body: webhook, options: options)
        }

        /// Fetches a sub-merchant's webhook.
        public func fetch(_ id: WebhookEndpoint.ID, account: AccountID, options: RequestOptions = .init()) async throws -> WebhookEndpoint {
            try await handler.perform(.GET, "\(webhooksPath(account).get())/\(id.pathComponent().get())", options: options)
        }

        /// Lists webhooks, fetching pages lazily. Pass `account` for a sub-merchant's webhooks.
        public func list(account: AccountID? = nil, _ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<WebhookEndpoint> {
            RazorpayList(handler: handler, path: webhooksPath(account), options: list, request: options)
        }

        /// Replaces a webhook's URL, events and alert email. Uses `PUT` on your own account and `PATCH` on a sub-merchant's.
        public func update(_ id: WebhookEndpoint.ID, account: AccountID? = nil, _ changes: WebhookEndpoint.Update, options: RequestOptions = .init()) async throws -> WebhookEndpoint {
            try await handler.perform(account == nil ? .PUT : .PATCH, "\(webhooksPath(account).get())/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Deletes a sub-merchant's webhook.
        public func delete(_ id: WebhookEndpoint.ID, account: AccountID, options: RequestOptions = .init()) async throws {
            try await handler.resultIgnoringBody(.DELETE, "\(webhooksPath(account).get())/\(id.pathComponent().get())", options: options).get()
        }
}
#endif
