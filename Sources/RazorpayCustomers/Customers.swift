import Foundation
import NIOHTTP1
import RazorpayCore

extension RazorpayClient {
    /// Customers: create, fetch, list, update. See https://razorpay.com/docs/api/customers/.
    public var customers: Customers { Customers(handler: handler) }

    /// Customers: create, fetch, list, update. See https://razorpay.com/docs/api/customers/.
    public struct Customers: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
#if compiler(>=6.0)
extension RazorpayClient.Customers {
        /// Creates a customer, or returns the existing one with the same email and contact.
        public func create(_ customer: Customer.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> Customer {
            try await handler.perform(.POST, "/v1/customers", body: customer, options: options)
        }

        /// Fetches a customer.
        public func fetch(_ id: Customer.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Customer {
            try await handler.perform(.GET, "/v1/customers/\(id.pathComponent().get())", options: options)
        }

        /// Lists customers, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Customer> {
            RazorpayList(handler: handler, path: "/v1/customers", options: list, request: options)
        }

        /// Updates a customer's name, email or contact.
        public func update(_ id: Customer.ID, _ changes: Customer.Update, options: RequestOptions = .init()) async throws(RazorpayError) -> Customer {
            try await handler.perform(.PUT, "/v1/customers/\(id.pathComponent().get())", body: changes, options: options)
        }
}
#else
extension RazorpayClient.Customers {
        /// Creates a customer, or returns the existing one with the same email and contact.
        public func create(_ customer: Customer.Create, options: RequestOptions = .init()) async throws -> Customer {
            try await handler.perform(.POST, "/v1/customers", body: customer, options: options)
        }

        /// Fetches a customer.
        public func fetch(_ id: Customer.ID, options: RequestOptions = .init()) async throws -> Customer {
            try await handler.perform(.GET, "/v1/customers/\(id.pathComponent().get())", options: options)
        }

        /// Lists customers, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Customer> {
            RazorpayList(handler: handler, path: "/v1/customers", options: list, request: options)
        }

        /// Updates a customer's name, email or contact.
        public func update(_ id: Customer.ID, _ changes: Customer.Update, options: RequestOptions = .init()) async throws -> Customer {
            try await handler.perform(.PUT, "/v1/customers/\(id.pathComponent().get())", body: changes, options: options)
        }
}
#endif
