import Foundation
import RazorpayCore

#if compiler(>=6.0)
extension RazorpayClient.PaymentLinks {
    /// Creates a Payment Link and returns it with its `shortURL`.
    public func create(_ link: PaymentLink.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> PaymentLink {
        try await handler.perform(.POST, "/v1/payment_links", body: link.validate().get(), options: options)
    }

    /// Fetches a Payment Link.
    public func fetch(_ id: PaymentLink.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> PaymentLink {
        try await handler.perform(.GET, "/v1/payment_links/\(id.pathComponent().get())", options: options)
    }

    /// Lists Payment Links, optionally only those for a payment or with a reference ID. Not paginated.
    public func list(paymentID: PaymentID? = nil, referenceID: String? = nil, options: RequestOptions = .init()) async throws(RazorpayError) -> [PaymentLink] {
        var query: [String: String] = [:]
        query["payment_id"] = paymentID?.rawValue
        query["reference_id"] = referenceID
        let page: PaymentLinkList = try await handler.perform(.GET, "/v1/payment_links", query: query, options: options)
        return page.paymentLinks
    }

    /// Updates a link's reference ID, expiry, partial-payment or reminder settings, or notes.
    public func update(_ id: PaymentLink.ID, _ changes: PaymentLink.Update, options: RequestOptions = .init()) async throws(RazorpayError) -> PaymentLink {
        try await handler.perform(.PATCH, "/v1/payment_links/\(id.pathComponent().get())", body: changes, options: options)
    }

    /// Cancels a link so it can no longer be paid.
    public func cancel(_ id: PaymentLink.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> PaymentLink {
        try await handler.perform(.POST, "/v1/payment_links/\(id.pathComponent().get())/cancel", options: options)
    }

    /// Resends the link to the customer by SMS or email.
    @discardableResult
    public func notify(_ id: PaymentLink.ID, via medium: PaymentLink.Medium, options: RequestOptions = .init()) async throws(RazorpayError) -> SuccessResult {
        let path = try "/v1/payment_links/\(id.pathComponent().get())/notify_by/\(RazorpayID<PaymentLink.Medium>(medium.rawValue).pathComponent().get())"
        return try await handler.perform(.POST, path, options: options)
    }
}
#else
extension RazorpayClient.PaymentLinks {
    /// Creates a Payment Link and returns it with its `shortURL`.
    public func create(_ link: PaymentLink.Create, options: RequestOptions = .init()) async throws -> PaymentLink {
        try await handler.perform(.POST, "/v1/payment_links", body: link.validate().get(), options: options)
    }

    /// Fetches a Payment Link.
    public func fetch(_ id: PaymentLink.ID, options: RequestOptions = .init()) async throws -> PaymentLink {
        try await handler.perform(.GET, "/v1/payment_links/\(id.pathComponent().get())", options: options)
    }

    /// Lists Payment Links, optionally only those for a payment or with a reference ID. Not paginated.
    public func list(paymentID: PaymentID? = nil, referenceID: String? = nil, options: RequestOptions = .init()) async throws -> [PaymentLink] {
        var query: [String: String] = [:]
        query["payment_id"] = paymentID?.rawValue
        query["reference_id"] = referenceID
        let page: PaymentLinkList = try await handler.perform(.GET, "/v1/payment_links", query: query, options: options)
        return page.paymentLinks
    }

    /// Updates a link's reference ID, expiry, partial-payment or reminder settings, or notes.
    public func update(_ id: PaymentLink.ID, _ changes: PaymentLink.Update, options: RequestOptions = .init()) async throws -> PaymentLink {
        try await handler.perform(.PATCH, "/v1/payment_links/\(id.pathComponent().get())", body: changes, options: options)
    }

    /// Cancels a link so it can no longer be paid.
    public func cancel(_ id: PaymentLink.ID, options: RequestOptions = .init()) async throws -> PaymentLink {
        try await handler.perform(.POST, "/v1/payment_links/\(id.pathComponent().get())/cancel", options: options)
    }

    /// Resends the link to the customer by SMS or email.
    @discardableResult
    public func notify(_ id: PaymentLink.ID, via medium: PaymentLink.Medium, options: RequestOptions = .init()) async throws -> SuccessResult {
        let path = try "/v1/payment_links/\(id.pathComponent().get())/notify_by/\(RazorpayID<PaymentLink.Medium>(medium.rawValue).pathComponent().get())"
        return try await handler.perform(.POST, path, options: options)
    }
}
#endif
