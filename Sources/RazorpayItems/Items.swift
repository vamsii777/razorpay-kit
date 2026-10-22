import Foundation
import NIOHTTP1
import RazorpayCore

extension RazorpayClient {
    /// Items: create, fetch, list, update, delete. See https://razorpay.com/docs/api/payments/items/.
    public var items: Items { Items(handler: handler) }

    /// Items: create, fetch, list, update, delete. See https://razorpay.com/docs/api/payments/items/.
    public struct Items: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
#if compiler(>=6.0)
extension RazorpayClient.Items {
        /// Creates an item.
        public func create(_ item: Item.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> Item {
            try await handler.perform(.POST, "/v1/items", body: item, options: options)
        }

        /// Fetches an item.
        public func fetch(_ id: Item.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Item {
            try await handler.perform(.GET, "/v1/items/\(id.pathComponent().get())", options: options)
        }

        /// Lists items, fetching pages lazily. Filter with `ListOptions(filters: ["active": "1"])`.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Item> {
            RazorpayList(handler: handler, path: "/v1/items", options: list, request: options)
        }

        /// Updates an item. Only non-nil fields are sent.
        public func update(_ id: Item.ID, _ changes: Item.Update, options: RequestOptions = .init()) async throws(RazorpayError) -> Item {
            try await handler.perform(.PATCH, "/v1/items/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Deletes an item. Items already used in an invoice can't be deleted.
        public func delete(_ id: Item.ID, options: RequestOptions = .init()) async throws(RazorpayError) {
            try await handler.resultIgnoringBody(.DELETE, "/v1/items/\(id.pathComponent().get())", options: options).get()
        }
}
#else
extension RazorpayClient.Items {
        /// Creates an item.
        public func create(_ item: Item.Create, options: RequestOptions = .init()) async throws -> Item {
            try await handler.perform(.POST, "/v1/items", body: item, options: options)
        }

        /// Fetches an item.
        public func fetch(_ id: Item.ID, options: RequestOptions = .init()) async throws -> Item {
            try await handler.perform(.GET, "/v1/items/\(id.pathComponent().get())", options: options)
        }

        /// Lists items, fetching pages lazily. Filter with `ListOptions(filters: ["active": "1"])`.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Item> {
            RazorpayList(handler: handler, path: "/v1/items", options: list, request: options)
        }

        /// Updates an item. Only non-nil fields are sent.
        public func update(_ id: Item.ID, _ changes: Item.Update, options: RequestOptions = .init()) async throws -> Item {
            try await handler.perform(.PATCH, "/v1/items/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Deletes an item. Items already used in an invoice can't be deleted.
        public func delete(_ id: Item.ID, options: RequestOptions = .init()) async throws {
            try await handler.resultIgnoringBody(.DELETE, "/v1/items/\(id.pathComponent().get())", options: options).get()
        }
}
#endif
