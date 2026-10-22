import Foundation
import RazorpayCore
import RazorpayPayments

#if compiler(>=6.0)
extension RazorpayClient.Payments {
        /// Refunds a captured payment, fully by default.
        public func refund(_ id: Payment.ID, _ refund: Refund.Create = .full, options: RequestOptions = .init()) async throws(RazorpayError) -> Refund {
            try await handler.perform(.POST, "/v1/payments/\(id.pathComponent().get())/refund", body: refund, options: options)
        }

        /// Lists the refunds of one payment.
        public func refunds(of id: Payment.ID, _ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Refund> {
            RazorpayList(handler: handler, path: id.pathComponent().map { "/v1/payments/\($0)/refunds" }, options: list, request: options)
        }
}
#else
extension RazorpayClient.Payments {
        /// Refunds a captured payment, fully by default.
        public func refund(_ id: Payment.ID, _ refund: Refund.Create = .full, options: RequestOptions = .init()) async throws -> Refund {
            try await handler.perform(.POST, "/v1/payments/\(id.pathComponent().get())/refund", body: refund, options: options)
        }

        /// Lists the refunds of one payment.
        public func refunds(of id: Payment.ID, _ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Refund> {
            RazorpayList(handler: handler, path: id.pathComponent().map { "/v1/payments/\($0)/refunds" }, options: list, request: options)
        }
}
#endif
