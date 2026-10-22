import Foundation
import NIOHTTP1
import RazorpayCore
import RazorpayPayments
extension RazorpayClient {
    /// Refunds: fetch, list, update. Create refunds with `payments.refund(_:_:options:)`. See https://razorpay.com/docs/api/refunds/.
    public var refunds: Refunds { Refunds(handler: handler) }

    /// Refunds: fetch, list, update. Create refunds with `payments.refund(_:_:options:)`. See https://razorpay.com/docs/api/refunds/.
    public struct Refunds: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}
#if compiler(>=6.0)
extension RazorpayClient.Refunds {
        /// Fetches a refund.
        public func fetch(_ id: Refund.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Refund {
            try await handler.perform(.GET, "/v1/refunds/\(id.pathComponent().get())", options: options)
        }

        /// Lists refunds, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Refund> {
            RazorpayList(handler: handler, path: "/v1/refunds", options: list, request: options)
        }

        /// Replaces a refund's notes.
        public func update(_ id: Refund.ID, notes: Notes, options: RequestOptions = .init()) async throws(RazorpayError) -> Refund {
            try await handler.perform(.PATCH, "/v1/refunds/\(id.pathComponent().get())", body: NotesBody(notes: notes), options: options)
        }
}
#else
extension RazorpayClient.Refunds {
        /// Fetches a refund.
        public func fetch(_ id: Refund.ID, options: RequestOptions = .init()) async throws -> Refund {
            try await handler.perform(.GET, "/v1/refunds/\(id.pathComponent().get())", options: options)
        }

        /// Lists refunds, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Refund> {
            RazorpayList(handler: handler, path: "/v1/refunds", options: list, request: options)
        }

        /// Replaces a refund's notes.
        public func update(_ id: Refund.ID, notes: Notes, options: RequestOptions = .init()) async throws -> Refund {
            try await handler.perform(.PATCH, "/v1/refunds/\(id.pathComponent().get())", body: NotesBody(notes: notes), options: options)
        }
}
#endif
