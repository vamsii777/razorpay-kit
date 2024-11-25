import Foundation
import NIO
import NIOHTTP1
import AsyncHTTPClient

/// A protocol defining the routes for interacting with payments in the Razorpay API.
///
/// This protocol provides a comprehensive interface for managing payments through the Razorpay payment gateway.
/// It includes methods for creating, fetching, capturing, refunding payments as well as handling UPI transactions,
/// card details, and OTP-based authentication.
///
/// ## Topics
///
/// ### Payment Management
/// - ``all(queryParams:extraHeaders:)``
/// - ``fetch(paymentID:queryParams:extraHeaders:)``
/// - ``capture(paymentID:amount:data:extraHeaders:)``
/// - ``edit(paymentID:data:extraHeaders:)``
///
/// ### Refunds
/// - ``refund(paymentID:amount:data:extraHeaders:)``
/// - ``fetchMultipleRefund(paymentId:queryParams:extraHeaders:)``
/// - ``fetchRefund(paymentId:refundId:queryParams:extraHeaders:)``
///
/// ### Transfers
/// - ``transfer(paymentID:data:extraHeaders:)``
/// - ``transfers(paymentID:queryParams:extraHeaders:)``
/// - ``bankTransfer(paymentID:queryParams:extraHeaders:)``
///
/// ### Payment Creation
/// - ``createPaymentJson(data:extraHeaders:)``
/// - ``createRecurringPayment(data:extraHeaders:)``
/// - ``createUpi(data:extraHeaders:)``
///
/// ### Card & UPI Operations
/// - ``fetchCardDetails(paymentID:queryParams:extraHeaders:)``
/// - ``validateVpa(data:extraHeaders:)``
///
/// ### System Status
/// - ``fetchPaymentDowntime(queryParams:extraHeaders:)``
/// - ``fetchPaymentDowntimeById(downtimeId:queryParams:extraHeaders:)``
///
/// ### OTP Management
/// - ``otpGenerate(paymentId:queryParams:extraHeaders:)``
/// - ``otpSubmit(paymentId:data:extraHeaders:)``
/// - ``otpResend(paymentId:queryParams:extraHeaders:)``
public protocol PaymentRoutes: RazorpayAPIRoute {
    
    /// Fetches all payments with optional query parameters and extra headers.
    /// - Parameters:
    ///   - queryParams: Optional query parameters to filter the payments
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the payment information
    /// - Throws: An error if the request fails
    func all(queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches a payment by its ID.
    /// - Parameters:
    ///   - paymentID: The unique identifier of the payment
    ///   - queryParams: Optional query parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the payment details
    /// - Throws: An error if the request fails
    func fetch(paymentID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Captures a payment with the given ID and amount.
    /// - Parameters:
    ///   - paymentID: The unique identifier of the payment to capture
    ///   - amount: The amount to capture in smallest currency unit (e.g., paise for INR)
    ///   - data: Additional data for the capture request
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the capture response
    /// - Throws: An error if the capture fails
    func capture(paymentID: String, amount: Int, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Initiates a refund for a payment with the given ID and amount.
    /// - Parameters:
    ///   - paymentID: The unique identifier of the payment to refund
    ///   - amount: The amount to refund in smallest currency unit
    ///   - data: Additional data for the refund request
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the refund details
    /// - Throws: An error if the refund fails
    func refund(paymentID: String, amount: Int, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a transfer for a payment with the given ID.
    /// - Parameters:
    ///   - paymentID: The unique identifier of the payment
    ///   - data: Transfer details and parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the transfer details
    /// - Throws: An error if the transfer creation fails
    func transfer(paymentID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches all transfers associated with a payment ID.
    /// - Parameters:
    ///   - paymentID: The unique identifier of the payment
    ///   - queryParams: Optional query parameters to filter transfers
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the transfers information
    /// - Throws: An error if the request fails
    func transfers(paymentID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches bank transfer details associated with a payment ID.
    /// - Parameters:
    ///   - paymentID: The unique identifier of the payment
    ///   - queryParams: Optional query parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the bank transfer details
    /// - Throws: An error if the request fails
    func bankTransfer(paymentID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a JSON payment with the given data.
    /// - Parameters:
    ///   - data: Payment details and parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the created payment details
    /// - Throws: An error if the payment creation fails
    func createPaymentJson(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a recurring payment with the given data.
    /// - Parameters:
    ///   - data: Recurring payment details and parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the recurring payment details
    /// - Throws: An error if the recurring payment creation fails
    func createRecurringPayment(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Updates a payment with the given ID and data.
    /// - Parameters:
    ///   - paymentID: The unique identifier of the payment to update
    ///   - data: Updated payment details
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the updated payment details
    /// - Throws: An error if the update fails
    func edit(paymentID: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches card details for a payment with the given ID.
    /// - Parameters:
    ///   - paymentID: The unique identifier of the payment
    ///   - queryParams: Optional query parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the card details
    /// - Throws: An error if the request fails
    func fetchCardDetails(paymentID: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches payment downtime details.
    /// - Parameters:
    ///   - queryParams: Optional query parameters to filter downtime information
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the downtime details
    /// - Throws: An error if the request fails
    func fetchPaymentDowntime(queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches payment downtime details by ID.
    /// - Parameters:
    ///   - downtimeId: The unique identifier of the downtime period
    ///   - queryParams: Optional query parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the specific downtime details
    /// - Throws: An error if the request fails
    func fetchPaymentDowntimeById(downtimeId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches multiple refund details for a payment ID.
    /// - Parameters:
    ///   - paymentId: The unique identifier of the payment
    ///   - queryParams: Optional query parameters to filter refunds
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing multiple refund details
    /// - Throws: An error if the request fails
    func fetchMultipleRefund(paymentId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches refund detail with the given payment and refund IDs.
    /// - Parameters:
    ///   - paymentId: The unique identifier of the payment
    ///   - refundId: The unique identifier of the refund
    ///   - queryParams: Optional query parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the specific refund details
    /// - Throws: An error if the request fails
    func fetchRefund(paymentId: String, refundId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Creates a UPI payment with the given data.
    /// - Parameters:
    ///   - data: UPI payment details and parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the UPI payment details
    /// - Throws: An error if the UPI payment creation fails
    func createUpi(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Validates a VPA with the given data.
    /// - Parameters:
    ///   - data: VPA details to validate
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the validation result
    /// - Throws: An error if the validation fails
    func validateVpa(data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Fetches payment methods with the given data.
    /// - Parameters:
    ///   - data: Optional parameters to filter payment methods
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing available payment methods
    /// - Throws: An error if the request fails
    func fetchMethods(data: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Generates OTP for a payment with the given ID.
    /// - Parameters:
    ///   - paymentId: The unique identifier of the payment
    ///   - queryParams: Optional query parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the OTP generation response
    /// - Throws: An error if the OTP generation fails
    func otpGenerate(paymentId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Submits OTP for a payment with the given ID and data.
    /// - Parameters:
    ///   - paymentId: The unique identifier of the payment
    ///   - data: OTP and related data
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the OTP submission response
    /// - Throws: An error if the OTP submission fails
    func otpSubmit(paymentId: String, data: [String: Any], extraHeaders: [String: String]?) async throws -> [String: Any]
    
    /// Resends OTP for a payment with the given ID.
    /// - Parameters:
    ///   - paymentId: The unique identifier of the payment
    ///   - queryParams: Optional query parameters
    ///   - extraHeaders: Optional additional headers for the request
    /// - Returns: A dictionary containing the OTP resend response
    /// - Throws: An error if the OTP resend fails
    func otpResend(paymentId: String, queryParams: [String: String]?, extraHeaders: [String: String]?) async throws -> [String: Any]
}

/// A struct implementing the `PaymentRoutes` protocol for Razorpay payment operations.
///
/// This struct provides the concrete implementation of all payment-related operations
/// defined in the ``PaymentRoutes`` protocol. It handles the actual HTTP requests to
/// the Razorpay API endpoints and processes the responses.
///
/// ## Topics
///
/// ### Initialization
/// ```swift
/// let client = RazorpayAPIHandler()
/// let paymentRoutes = RazorpayPaymentRoutes(client: client)
/// ```
///
/// ### Usage Example
/// ```swift
/// // Fetch payment details
/// let paymentDetails = try await paymentRoutes.fetch(paymentID: "pay_123456")
///
/// // Create a new payment
/// let paymentData = ["amount": 1000, "currency": "INR"]
/// let newPayment = try await paymentRoutes.createPaymentJson(data: paymentData)
/// ```
public struct RazorpayPaymentRoutes: PaymentRoutes {
    public var headers: HTTPHeaders = [:]
    private let client: RazorpayAPIHandler

    init(client: RazorpayAPIHandler) {
        self.client = client
    }
    
    public func all(queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetch(paymentID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentID)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func capture(paymentID: String, amount: Int, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        var captureData = data
        captureData["amount"] = amount
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentID)/capture"
        let requestBody = try HTTPClientRequest.Body.json(captureData)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func refund(paymentID: String, amount: Int, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        var refundData = data
        refundData["amount"] = amount
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentID)/refund"
        let requestBody = try HTTPClientRequest.Body.json(refundData)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func transfer(paymentID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentID)/transfers"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func transfers(paymentID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentID)/transfers"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func bankTransfer(paymentID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentID)/bank_transfer"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func createPaymentJson(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/create/json"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func createRecurringPayment(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/create/recurring"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func edit(paymentID: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentID)"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .PATCH, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetchCardDetails(paymentID: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentID)/card"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetchPaymentDowntime(queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/downtimes"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetchPaymentDowntimeById(downtimeId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/downtimes/\(downtimeId)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetchMultipleRefund(paymentId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentId)/refunds"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetchRefund(paymentId: String, refundId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentId)/refunds/\(refundId)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func createUpi(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/create/upi"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func validateVpa(data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/validate/vpa"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func fetchMethods(data: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.methodsURL)"
        let response = try await client.sendRequest(method: .GET, path: url, queryParams: data, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func otpGenerate(paymentId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentId)/otp_generate"
        let response = try await client.sendRequest(method: .POST, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func otpSubmit(paymentId: String, data: [String: Any], extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentId)/otp/submit"
        let requestBody = try HTTPClientRequest.Body.json(data)
        let response = try await client.sendRequest(method: .POST, path: url, body: requestBody, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }

    public func otpResend(paymentId: String, queryParams: [String: String]? = nil, extraHeaders: [String: String]? = nil) async throws -> [String: Any] {
        let url = "\(APIConstants.v1)\(APIConstants.paymentURL)/\(paymentId)/otp/resend"
        let response = try await client.sendRequest(method: .POST, path: url, queryParams: queryParams, headers: RZPRUTL.convertToHTTPHeaders(extraHeaders))
        return try await RZPRUTL.processResponse(response)
    }
}
