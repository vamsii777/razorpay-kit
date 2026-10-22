import Foundation
import RazorpayCore
import RazorpayPayments

#if compiler(>=6.0)
extension RazorpayClient.QRCodes {
    /// Creates a QR code.
    public func create(_ qr: QRCode.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> QRCode {
        try await handler.perform(.POST, "/v1/payments/qr_codes", body: qr.validate().get(), options: options)
    }

    /// Fetches a QR code.
    public func fetch(_ id: QRCode.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> QRCode {
        try await handler.perform(.GET, "/v1/payments/qr_codes/\(id.pathComponent().get())", options: options)
    }

    /// Lists QR codes, newest first, fetching pages lazily. Filter with `ListOptions.filters`
    /// (`customer_id`, `payment_id`).
    public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<QRCode> {
        RazorpayList(handler: handler, path: "/v1/payments/qr_codes", options: list, request: options)
    }

    /// Lists the payments made to a QR code.
    public func payments(of id: QRCode.ID, _ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Payment> {
        RazorpayList(handler: handler, path: id.pathComponent().map { "/v1/payments/qr_codes/\($0)/payments" }, options: list, request: options)
    }

    /// Closes a QR code so it stops accepting payments.
    public func close(_ id: QRCode.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> QRCode {
        try await handler.perform(.POST, "/v1/payments/qr_codes/\(id.pathComponent().get())/close", options: options)
    }
}
#else
extension RazorpayClient.QRCodes {
    /// Creates a QR code.
    public func create(_ qr: QRCode.Create, options: RequestOptions = .init()) async throws -> QRCode {
        try await handler.perform(.POST, "/v1/payments/qr_codes", body: qr.validate().get(), options: options)
    }

    /// Fetches a QR code.
    public func fetch(_ id: QRCode.ID, options: RequestOptions = .init()) async throws -> QRCode {
        try await handler.perform(.GET, "/v1/payments/qr_codes/\(id.pathComponent().get())", options: options)
    }

    /// Lists QR codes, newest first, fetching pages lazily. Filter with `ListOptions.filters`
    /// (`customer_id`, `payment_id`).
    public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<QRCode> {
        RazorpayList(handler: handler, path: "/v1/payments/qr_codes", options: list, request: options)
    }

    /// Lists the payments made to a QR code.
    public func payments(of id: QRCode.ID, _ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Payment> {
        RazorpayList(handler: handler, path: id.pathComponent().map { "/v1/payments/qr_codes/\($0)/payments" }, options: list, request: options)
    }

    /// Closes a QR code so it stops accepting payments.
    public func close(_ id: QRCode.ID, options: RequestOptions = .init()) async throws -> QRCode {
        try await handler.perform(.POST, "/v1/payments/qr_codes/\(id.pathComponent().get())/close", options: options)
    }
}
#endif
