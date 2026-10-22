import Foundation
import NIOHTTP1
import RazorpayCore

extension RazorpayClient {
    /// Payments: fetch, list, capture, update. See https://razorpay.com/docs/api/payments/.
    public var payments: Payments { Payments(handler: handler) }

    /// Payments: fetch, list, capture, update. See https://razorpay.com/docs/api/payments/.
    public struct Payments: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
#if compiler(>=6.0)
extension RazorpayClient.Payments {
        /// Fetches a payment.
        public func fetch(_ id: Payment.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Payment {
            try await handler.perform(.GET, "/v1/payments/\(id.pathComponent().get())", options: options)
        }

        /// Lists payments, newest first, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Payment> {
            RazorpayList(handler: handler, path: "/v1/payments", options: list, request: options)
        }

        /// Captures an authorized payment. `amount` must equal the authorized amount.
        public func capture(_ id: Payment.ID, amount: Money, options: RequestOptions = .init()) async throws(RazorpayError) -> Payment {
            try await handler.perform(.POST, "/v1/payments/\(id.pathComponent().get())/capture", body: CaptureBody(amount: amount.amount, currency: amount.currency), options: options)
        }

        /// Replaces a payment's notes.
        public func update(_ id: Payment.ID, notes: Notes, options: RequestOptions = .init()) async throws(RazorpayError) -> Payment {
            try await handler.perform(.PATCH, "/v1/payments/\(id.pathComponent().get())", body: NotesBody(notes: notes), options: options)
        }
}
#else
extension RazorpayClient.Payments {
        /// Fetches a payment.
        public func fetch(_ id: Payment.ID, options: RequestOptions = .init()) async throws -> Payment {
            try await handler.perform(.GET, "/v1/payments/\(id.pathComponent().get())", options: options)
        }

        /// Lists payments, newest first, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Payment> {
            RazorpayList(handler: handler, path: "/v1/payments", options: list, request: options)
        }

        /// Captures an authorized payment. `amount` must equal the authorized amount.
        public func capture(_ id: Payment.ID, amount: Money, options: RequestOptions = .init()) async throws -> Payment {
            try await handler.perform(.POST, "/v1/payments/\(id.pathComponent().get())/capture", body: CaptureBody(amount: amount.amount, currency: amount.currency), options: options)
        }

        /// Replaces a payment's notes.
        public func update(_ id: Payment.ID, notes: Notes, options: RequestOptions = .init()) async throws -> Payment {
            try await handler.perform(.PATCH, "/v1/payments/\(id.pathComponent().get())", body: NotesBody(notes: notes), options: options)
        }
}
#endif

struct CaptureBody: Encodable, Sendable {
    let amount: Int
    let currency: Currency
}
