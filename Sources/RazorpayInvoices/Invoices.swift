import Foundation
import NIOHTTP1
import RazorpayCore

extension RazorpayClient {
    /// Invoices: create, issue, notify, cancel, update, delete. See https://razorpay.com/docs/api/payments/invoices/.
    public var invoices: Invoices { Invoices(handler: handler) }

    /// Invoices: create, issue, notify, cancel, update, delete. See https://razorpay.com/docs/api/payments/invoices/.
    public struct Invoices: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}

private struct NotifyResult: Decodable, Sendable { let success: Bool? }
#if compiler(>=6.0)
extension RazorpayClient.Invoices {
        /// Creates an invoice, or a draft when `draft` is `true`.
        public func create(_ invoice: Invoice.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> Invoice {
            try await handler.perform(.POST, "/v1/invoices", body: invoice, options: options)
        }

        /// Fetches an invoice.
        public func fetch(_ id: Invoice.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Invoice {
            try await handler.perform(.GET, "/v1/invoices/\(id.pathComponent().get())", options: options)
        }

        /// Lists invoices, fetching pages lazily. Filter with `filters`, for example `["type": "invoice", "customer_id": "cust_…"]`.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Invoice> {
            RazorpayList(handler: handler, path: "/v1/invoices", options: list, request: options)
        }

        /// Updates an invoice. Only non-nil fields are sent.
        public func update(_ id: Invoice.ID, _ changes: Invoice.Update, options: RequestOptions = .init()) async throws(RazorpayError) -> Invoice {
            try await handler.perform(.PATCH, "/v1/invoices/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Issues a draft invoice.
        public func issue(_ id: Invoice.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Invoice {
            try await handler.perform(.POST, "/v1/invoices/\(id.pathComponent().get())/issue", options: options)
        }

        /// Cancels an issued invoice.
        public func cancel(_ id: Invoice.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Invoice {
            try await handler.perform(.POST, "/v1/invoices/\(id.pathComponent().get())/cancel", options: options)
        }

        /// Deletes a draft invoice.
        public func delete(_ id: Invoice.ID, options: RequestOptions = .init()) async throws(RazorpayError) {
            try await handler.resultIgnoringBody(.DELETE, "/v1/invoices/\(id.pathComponent().get())", options: options).get()
        }

        /// Re-sends the invoice by SMS or email. Returns Razorpay's `success` flag.
        @discardableResult
        public func notify(_ id: Invoice.ID, by medium: Invoice.Medium, options: RequestOptions = .init()) async throws(RazorpayError) -> Bool {
            let path = "/v1/invoices/\(try id.pathComponent().get())/notify_by/\(RZPRUTL.percentEncode(medium.rawValue))"
            return try await handler.perform(.POST, path, options: options, as: NotifyResult.self).success ?? true
        }
}
#else
extension RazorpayClient.Invoices {
        /// Creates an invoice, or a draft when `draft` is `true`.
        public func create(_ invoice: Invoice.Create, options: RequestOptions = .init()) async throws -> Invoice {
            try await handler.perform(.POST, "/v1/invoices", body: invoice, options: options)
        }

        /// Fetches an invoice.
        public func fetch(_ id: Invoice.ID, options: RequestOptions = .init()) async throws -> Invoice {
            try await handler.perform(.GET, "/v1/invoices/\(id.pathComponent().get())", options: options)
        }

        /// Lists invoices, fetching pages lazily. Filter with `filters`, for example `["type": "invoice", "customer_id": "cust_…"]`.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Invoice> {
            RazorpayList(handler: handler, path: "/v1/invoices", options: list, request: options)
        }

        /// Updates an invoice. Only non-nil fields are sent.
        public func update(_ id: Invoice.ID, _ changes: Invoice.Update, options: RequestOptions = .init()) async throws -> Invoice {
            try await handler.perform(.PATCH, "/v1/invoices/\(id.pathComponent().get())", body: changes, options: options)
        }

        /// Issues a draft invoice.
        public func issue(_ id: Invoice.ID, options: RequestOptions = .init()) async throws -> Invoice {
            try await handler.perform(.POST, "/v1/invoices/\(id.pathComponent().get())/issue", options: options)
        }

        /// Cancels an issued invoice.
        public func cancel(_ id: Invoice.ID, options: RequestOptions = .init()) async throws -> Invoice {
            try await handler.perform(.POST, "/v1/invoices/\(id.pathComponent().get())/cancel", options: options)
        }

        /// Deletes a draft invoice.
        public func delete(_ id: Invoice.ID, options: RequestOptions = .init()) async throws {
            try await handler.resultIgnoringBody(.DELETE, "/v1/invoices/\(id.pathComponent().get())", options: options).get()
        }

        /// Re-sends the invoice by SMS or email. Returns Razorpay's `success` flag.
        @discardableResult
        public func notify(_ id: Invoice.ID, by medium: Invoice.Medium, options: RequestOptions = .init()) async throws -> Bool {
            let path = "/v1/invoices/\(try id.pathComponent().get())/notify_by/\(RZPRUTL.percentEncode(medium.rawValue))"
            return try await handler.perform(.POST, path, options: options, as: NotifyResult.self).success ?? true
        }
}
#endif
