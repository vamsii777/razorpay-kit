import Foundation
import NIOHTTP1
import RazorpayCore

extension RazorpayClient {
    /// Subscription add-ons: create, fetch, list, delete.
    /// See https://razorpay.com/docs/api/payments/subscriptions/#create-an-add-on.
    public var addons: Addons { Addons(handler: handler) }

    /// Subscription add-ons: create, fetch, list, delete.
    /// See https://razorpay.com/docs/api/payments/subscriptions/#create-an-add-on.
    public struct Addons: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
#if compiler(>=6.0)
extension RazorpayClient.Addons {
        /// Adds a charge to a subscription's next invoice.
        public func create(for subscription: SubscriptionID, _ addon: Addon.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> Addon {
            try await handler.perform(.POST, "/v1/subscriptions/\(subscription.pathComponent().get())/addons", body: addon, options: options)
        }

        /// Fetches an add-on.
        public func fetch(_ id: Addon.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Addon {
            try await handler.perform(.GET, "/v1/addons/\(id.pathComponent().get())", options: options)
        }

        /// Lists add-ons, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Addon> {
            RazorpayList(handler: handler, path: "/v1/addons", options: list, request: options)
        }

        /// Deletes an add-on that hasn't been billed yet.
        public func delete(_ id: Addon.ID, options: RequestOptions = .init()) async throws(RazorpayError) {
            try await handler.resultIgnoringBody(.DELETE, "/v1/addons/\(id.pathComponent().get())", options: options).get()
        }
}
#else
extension RazorpayClient.Addons {
        /// Adds a charge to a subscription's next invoice.
        public func create(for subscription: SubscriptionID, _ addon: Addon.Create, options: RequestOptions = .init()) async throws -> Addon {
            try await handler.perform(.POST, "/v1/subscriptions/\(subscription.pathComponent().get())/addons", body: addon, options: options)
        }

        /// Fetches an add-on.
        public func fetch(_ id: Addon.ID, options: RequestOptions = .init()) async throws -> Addon {
            try await handler.perform(.GET, "/v1/addons/\(id.pathComponent().get())", options: options)
        }

        /// Lists add-ons, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Addon> {
            RazorpayList(handler: handler, path: "/v1/addons", options: list, request: options)
        }

        /// Deletes an add-on that hasn't been billed yet.
        public func delete(_ id: Addon.ID, options: RequestOptions = .init()) async throws {
            try await handler.resultIgnoringBody(.DELETE, "/v1/addons/\(id.pathComponent().get())", options: options).get()
        }
}
#endif
