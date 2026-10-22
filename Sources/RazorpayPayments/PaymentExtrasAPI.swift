import Foundation
import RazorpayCore

#if compiler(>=6.0)
extension RazorpayClient.Payments {
    /// Lists current and scheduled payment-method downtimes. The endpoint isn't paginated.
    public func downtimes(options: RequestOptions = .init()) async throws(RazorpayError) -> [Downtime] {
        let page: RazorpayCollection<Downtime> = try await handler.perform(.GET, "/v1/payments/downtimes", options: options)
        return page.items
    }

    /// Fetches one downtime.
    public func downtime(_ id: Downtime.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Downtime {
        try await handler.perform(.GET, "/v1/payments/downtimes/\(id.pathComponent().get())", options: options)
    }

    /// Checks that a UPI ID exists before sending a collect request.
    public func validateVPA(_ vpa: String, options: RequestOptions = .init()) async throws(RazorpayError) -> VPAValidation {
        try await handler.perform(.POST, "/v1/payments/validate/vpa", body: VPABody(vpa: required(vpa, "VPA").get()), options: options)
    }

    /// The card used for a payment.
    public func card(of id: Payment.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Card {
        try await handler.perform(.GET, "/v1/payments/\(id.pathComponent().get())/card", options: options)
    }

    /// The payment methods enabled on your account.
    public func methods(options: RequestOptions = .init()) async throws(RazorpayError) -> PaymentMethods {
        try await handler.perform(.GET, "/v1/methods", options: options)
    }

    /// Creates an S2S payment and returns the next action (usually a redirect or OTP step).
    public func create(_ request: PaymentRequest, options: RequestOptions = .init()) async throws(RazorpayError) -> PaymentResult {
        try await handler.perform(.POST, "/v1/payments/create/json", body: request, options: options)
    }

    /// Charges a saved token for a subsequent recurring payment.
    public func createRecurring(_ request: RecurringPaymentRequest, options: RequestOptions = .init()) async throws(RazorpayError) -> PaymentResult {
        _ = try required(request.token, "Token").get()
        return try await handler.perform(.POST, "/v1/payments/create/recurring", body: request, options: options)
    }

    /// Sends the card OTP for a native-OTP payment.
    public func generateOTP(for id: Payment.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> PaymentResult {
        try await handler.perform(.POST, "/v1/payments/\(id.pathComponent().get())/otp_generate", options: options)
    }

    /// Submits the OTP the customer entered.
    public func submitOTP(_ otp: String, for id: Payment.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> PaymentResult {
        let path = try "/v1/payments/\(id.pathComponent().get())/otp/submit"
        return try await handler.perform(.POST, path, body: OTPBody(otp: required(otp, "OTP").get()), options: options)
    }

    /// Sends the OTP again.
    public func resendOTP(for id: Payment.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> PaymentResult {
        try await handler.perform(.POST, "/v1/payments/\(id.pathComponent().get())/otp/resend", options: options)
    }
}
#else
extension RazorpayClient.Payments {
    /// Lists current and scheduled payment-method downtimes. The endpoint isn't paginated.
    public func downtimes(options: RequestOptions = .init()) async throws -> [Downtime] {
        let page: RazorpayCollection<Downtime> = try await handler.perform(.GET, "/v1/payments/downtimes", options: options)
        return page.items
    }

    /// Fetches one downtime.
    public func downtime(_ id: Downtime.ID, options: RequestOptions = .init()) async throws -> Downtime {
        try await handler.perform(.GET, "/v1/payments/downtimes/\(id.pathComponent().get())", options: options)
    }

    /// Checks that a UPI ID exists before sending a collect request.
    public func validateVPA(_ vpa: String, options: RequestOptions = .init()) async throws -> VPAValidation {
        try await handler.perform(.POST, "/v1/payments/validate/vpa", body: VPABody(vpa: required(vpa, "VPA").get()), options: options)
    }

    /// The card used for a payment.
    public func card(of id: Payment.ID, options: RequestOptions = .init()) async throws -> Card {
        try await handler.perform(.GET, "/v1/payments/\(id.pathComponent().get())/card", options: options)
    }

    /// The payment methods enabled on your account.
    public func methods(options: RequestOptions = .init()) async throws -> PaymentMethods {
        try await handler.perform(.GET, "/v1/methods", options: options)
    }

    /// Creates an S2S payment and returns the next action (usually a redirect or OTP step).
    public func create(_ request: PaymentRequest, options: RequestOptions = .init()) async throws -> PaymentResult {
        try await handler.perform(.POST, "/v1/payments/create/json", body: request, options: options)
    }

    /// Charges a saved token for a subsequent recurring payment.
    public func createRecurring(_ request: RecurringPaymentRequest, options: RequestOptions = .init()) async throws -> PaymentResult {
        _ = try required(request.token, "Token").get()
        return try await handler.perform(.POST, "/v1/payments/create/recurring", body: request, options: options)
    }

    /// Sends the card OTP for a native-OTP payment.
    public func generateOTP(for id: Payment.ID, options: RequestOptions = .init()) async throws -> PaymentResult {
        try await handler.perform(.POST, "/v1/payments/\(id.pathComponent().get())/otp_generate", options: options)
    }

    /// Submits the OTP the customer entered.
    public func submitOTP(_ otp: String, for id: Payment.ID, options: RequestOptions = .init()) async throws -> PaymentResult {
        let path = try "/v1/payments/\(id.pathComponent().get())/otp/submit"
        return try await handler.perform(.POST, path, body: OTPBody(otp: required(otp, "OTP").get()), options: options)
    }

    /// Sends the OTP again.
    public func resendOTP(for id: Payment.ID, options: RequestOptions = .init()) async throws -> PaymentResult {
        try await handler.perform(.POST, "/v1/payments/\(id.pathComponent().get())/otp/resend", options: options)
    }
}
#endif
