import Foundation
import NIOHTTP1
import RazorpayCore
import RazorpayPayments
extension RazorpayClient {
    /// Orders: create, fetch, list, update, payments. See https://razorpay.com/docs/api/orders/.
    public var orders: Orders { Orders(handler: handler) }

    /// Orders: create, fetch, list, update, payments. See https://razorpay.com/docs/api/orders/.
    public struct Orders: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
#if compiler(>=6.0)
extension RazorpayClient.Orders {
        /// Creates an order.
        public func create(_ order: Order.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> Order {
            try await handler.perform(.POST, "/v1/orders", body: order, options: options)
        }

        /// Fetches an order.
        public func fetch(_ id: Order.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Order {
            try await handler.perform(.GET, "/v1/orders/\(id.pathComponent().get())", options: options)
        }

        /// Lists orders, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Order> {
            RazorpayList(handler: handler, path: "/v1/orders", options: list, request: options)
        }

        /// Replaces an order's notes.
        public func update(_ id: Order.ID, notes: Notes, options: RequestOptions = .init()) async throws(RazorpayError) -> Order {
            try await handler.perform(.PATCH, "/v1/orders/\(id.pathComponent().get())", body: NotesBody(notes: notes), options: options)
        }

        /// Fetches every payment attempt on an order.
        public func payments(of id: Order.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> [Payment] {
            try await handler.perform(.GET, "/v1/orders/\(id.pathComponent().get())/payments", options: options, as: RazorpayCollection<Payment>.self).items
        }
}
#else
extension RazorpayClient.Orders {
        /// Creates an order.
        public func create(_ order: Order.Create, options: RequestOptions = .init()) async throws -> Order {
            try await handler.perform(.POST, "/v1/orders", body: order, options: options)
        }

        /// Fetches an order.
        public func fetch(_ id: Order.ID, options: RequestOptions = .init()) async throws -> Order {
            try await handler.perform(.GET, "/v1/orders/\(id.pathComponent().get())", options: options)
        }

        /// Lists orders, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Order> {
            RazorpayList(handler: handler, path: "/v1/orders", options: list, request: options)
        }

        /// Replaces an order's notes.
        public func update(_ id: Order.ID, notes: Notes, options: RequestOptions = .init()) async throws -> Order {
            try await handler.perform(.PATCH, "/v1/orders/\(id.pathComponent().get())", body: NotesBody(notes: notes), options: options)
        }

        /// Fetches every payment attempt on an order.
        public func payments(of id: Order.ID, options: RequestOptions = .init()) async throws -> [Payment] {
            try await handler.perform(.GET, "/v1/orders/\(id.pathComponent().get())/payments", options: options, as: RazorpayCollection<Payment>.self).items
        }
}
#endif
