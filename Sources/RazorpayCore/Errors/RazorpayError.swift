import Foundation

/// The single error type thrown by RazorpayKit.
///
/// Every failure maps to exactly one case, so `switch` gives you an exhaustive picture:
///
/// ```swift
/// do {
///     let payment = try await razorpay.payments.capture("pay_123", amount: .inr(paise: 5000))
/// } catch {
///     switch error {
///     case .api(let api) where api.field == "amount": showAmountError(api.description)
///     case .api(let api):            log(api.statusCode, api.code, api.reason)
///     case .decoding(let failure):   report(failure)
///     case .transport:               if error.isRetryable { retry() }
///     case .signatureMismatch:       reject()
///     case .invalidRequest(let why): assertionFailure(why)
///     }
/// }
/// ```
///
/// On Swift 6 compilers typed APIs declare `throws(RazorpayError)`, so `error` above is already
/// a ``RazorpayError``. On Swift 5.10 they use plain `throws` but still only throw this type.
/// See https://razorpay.com/docs/api/errors/.
///
/// ## Topics
/// ### Cases
/// - ``api(_:)``
/// - ``decoding(_:)``
/// - ``transport(_:)``
/// - ``signatureMismatch(_:)``
/// - ``invalidRequest(_:)``
/// ### Inspecting
/// - ``statusCode``
/// - ``code``
/// - ``field``
/// - ``reason``
/// - ``isRetryable``
public enum RazorpayError: Error, Sendable {
    /// Razorpay rejected the request: a non-2xx status, or a 2xx body carrying an `error` object.
    case api(APIError)

    /// The response arrived but could not be decoded (empty, garbled, or missing required fields).
    case decoding(DecodingFailure)

    /// The request never produced an HTTP response: DNS, TLS, timeout, connection reset, cancellation.
    case transport(any Error)

    /// A webhook or Checkout signature did not match.
    case signatureMismatch(SignatureKind)

    /// The SDK refused to send the request, for example an empty ID or an unencodable body.
    case invalidRequest(String)

    /// The error object Razorpay returns, plus the HTTP status.
    ///
    /// Fields Razorpay did not send are `nil`. No defaults are filled in.
    public struct APIError: Sendable, Codable, Hashable {
        /// The HTTP status of the response, or `nil` when unknown.
        public let statusCode: Int?
        /// The error code, for example ``ErrorCode/badRequestError``. Unknown codes are kept.
        public let code: ErrorCode?
        /// A readable description of the error.
        public let description: String
        /// Where the error came from, for example `business`.
        public let source: String?
        /// The payment step, for example `payment_initiation`.
        public let step: String?
        /// Why it happened, for example `input_validation_failed`.
        public let reason: String?
        /// The request field that caused the error, if any.
        public let field: String?
        /// Extra metadata about the error.
        public let metadata: [String: String]?

        /// A Razorpay error code. Open: codes this SDK does not know are kept in ``rawValue``.
        public struct ErrorCode: RazorpayStringEnum {
            public let rawValue: String
            public init(rawValue: String) { self.rawValue = rawValue }

            /// Invalid request parameters.
            public static let badRequestError = Self(rawValue: "BAD_REQUEST_ERROR")
            /// An error from the payment gateway.
            public static let gatewayError = Self(rawValue: "GATEWAY_ERROR")
            /// An internal Razorpay server error.
            public static let serverError = Self(rawValue: "SERVER_ERROR")
        }

        private enum CodingKeys: String, CodingKey {
            case statusCode = "status_code"
            case code, description, source, step, reason, field, metadata
        }

        /// Creates an API error. Fields you don't pass stay `nil`.
        public init(
            statusCode: Int? = nil,
            code: ErrorCode? = nil,
            description: String,
            source: String? = nil,
            step: String? = nil,
            reason: String? = nil,
            field: String? = nil,
            metadata: [String: String]? = nil
        ) {
            self.statusCode = statusCode
            self.code = code
            self.description = description
            self.source = source
            self.step = step
            self.reason = reason
            self.field = field
            self.metadata = metadata
        }

        /// Builds an error from Razorpay's `{"error": {...}}` object. Returns `nil` if there isn't one.
        public init?(errorObject response: [String: Any], statusCode: Int?) {
            guard let error = response["error"] as? [String: Any] else { return nil }
            func string(_ key: String) -> String? {
                (error[key] as? String).flatMap { $0.isEmpty || $0 == "NA" ? nil : $0 }
            }
            // Some entities (transfers) embed an `error` object whose fields are all null on success.
            guard string("code") != nil || string("description") != nil || (statusCode ?? 200) >= 400 else { return nil }
            self.init(
                statusCode: statusCode,
                code: string("code").map(ErrorCode.init(rawValue:)),
                description: string("description") ?? statusCode.map { "HTTP \($0)" } ?? "Unknown Razorpay error",
                source: string("source"),
                step: string("step"),
                reason: string("reason"),
                field: string("field"),
                metadata: (error["metadata"] as? [String: Any])?.mapValues { "\($0)" }
            )
        }

        /// Builds an error from a raw response body. Never fails: a garbled or empty body still
        /// yields an error carrying the status code.
        package init(statusCode: Int, body: Data) {
            let json = (try? JSONSerialization.jsonObject(with: body)) as? [String: Any]
            if let json, let parsed = APIError(errorObject: json, statusCode: statusCode) {
                self = parsed
            } else {
                let detail = body.isEmpty ? "an empty body" : "an unparseable error body"
                self.init(statusCode: statusCode, description: "HTTP \(statusCode) with \(detail)")
            }
        }
    }

    /// Why a successful response could not be turned into a model.
    public struct DecodingFailure: Sendable, Equatable, CustomStringConvertible {
        /// The HTTP status of the response.
        public let statusCode: Int?
        /// The type the SDK tried to decode, for example `Payment`.
        public let type: String
        /// The JSON path that failed, for example `items[2].amount`. Empty for top-level problems.
        public let path: String
        /// What went wrong. Never contains the response body, which may hold personal data.
        public let message: String

        public init(statusCode: Int? = nil, type: String, path: String = "", message: String) {
            self.statusCode = statusCode
            self.type = type
            self.path = path
            self.message = message
        }

        /// Describes a `DecodingError` (or any error) raised while decoding `type`.
        public init(_ error: any Error, type: Any.Type, statusCode: Int?) {
            let (path, message) = Self.describe(error)
            self.init(statusCode: statusCode, type: String(describing: type), path: path, message: message)
        }

        public var description: String {
            "Could not decode \(type)" + (path.isEmpty ? "" : " at \(path)") + ": \(message)"
        }

        private static func describe(_ error: any Error) -> (String, String) {
            func render(_ codingPath: [any CodingKey]) -> String {
                codingPath.reduce(into: "") { result, key in
                    if let index = key.intValue { result += "[\(index)]" } else { result += result.isEmpty ? key.stringValue : ".\(key.stringValue)" }
                }
            }
            guard let error = error as? DecodingError else { return ("", "\(error)") }
            switch error {
            case .keyNotFound(let key, let context):
                return (render(context.codingPath + [key]), "missing required field")
            case .valueNotFound(_, let context):
                return (render(context.codingPath), "unexpected null")
            case .typeMismatch(let type, let context):
                return (render(context.codingPath), "expected \(type)")
            case .dataCorrupted(let context):
                return (render(context.codingPath), context.underlyingError == nil ? context.debugDescription : "body is not valid JSON")
            @unknown default:
                return ("", "\(error)")
            }
        }
    }

    /// Which signature failed verification.
    public enum SignatureKind: String, Sendable, Equatable, CaseIterable {
        case webhook, payment, subscription, paymentLink
    }
}

// MARK: - Fluent inspection

extension RazorpayError {
    /// The underlying API error, when Razorpay returned one.
    public var apiError: APIError? {
        if case .api(let error) = self { return error }
        return nil
    }

    /// The HTTP status, for ``api(_:)`` and ``decoding(_:)``.
    public var statusCode: Int? {
        switch self {
        case .api(let error): return error.statusCode
        case .decoding(let failure): return failure.statusCode
        case .transport, .signatureMismatch, .invalidRequest: return nil
        }
    }

    /// Razorpay's error code, for example ``APIError/ErrorCode/badRequestError``.
    public var code: APIError.ErrorCode? { apiError?.code }
    /// The request field Razorpay blamed, for example `amount`.
    public var field: String? { apiError?.field }
    /// Razorpay's reason, for example `input_validation_failed`.
    public var reason: String? { apiError?.reason }
    /// Razorpay's source, for example `business` or `customer`.
    public var source: String? { apiError?.source }
    /// Razorpay's step, for example `payment_authorization`.
    public var step: String? { apiError?.step }

    /// `true` for failures that may succeed if retried with the same idempotency key:
    /// transport errors, HTTP 408/409/429 and 5xx. Cancellation is never retryable.
    public var isRetryable: Bool {
        switch self {
        case .transport(let error): return !(error is CancellationError)
        case .api(let error):
            guard let status = error.statusCode else { return error.code == .serverError }
            return status == 408 || status == 409 || status == 429 || (500...599).contains(status)
        case .decoding, .signatureMismatch, .invalidRequest: return false
        }
    }

    /// `true` when Razorpay rejected the API key or secret.
    public var isInvalidCredentials: Bool {
        guard let error = apiError else { return false }
        return error.statusCode == 401
            || (error.code == .badRequestError && error.description.contains("API <key/secret> provided is invalid"))
    }

    /// `true` when Razorpay rejected the `amount` field.
    public var isInvalidAmount: Bool { code == .badRequestError && field == "amount" }

    /// `true` when request validation failed, for example a required field is missing.
    public var isValidationFailure: Bool { code == .badRequestError && reason == "input_validation_failed" }

    /// `true` for HTTP 404.
    public var isNotFound: Bool { statusCode == 404 }

    /// `true` for HTTP 429.
    public var isRateLimited: Bool { statusCode == 429 }
}

extension RazorpayError: LocalizedError, CustomStringConvertible {
    public var errorDescription: String? { description }

    public var description: String {
        switch self {
        case .api(let error):
            var text = ""
            if let status = error.statusCode { text += "HTTP \(status) " }
            text += "[\(error.code?.rawValue ?? "unknown")] \(error.description)"
            if let field = error.field { text += " (field: \(field))" }
            if let reason = error.reason { text += " - \(reason)" }
            return text
        case .decoding(let failure): return failure.description
        case .transport(let error): return "Transport error: \(error)"
        case .signatureMismatch(let kind): return "The \(kind.rawValue) signature does not match"
        case .invalidRequest(let message): return "Invalid request: \(message)"
        }
    }
}

extension RazorpayError {
    /// Wraps any error as a ``RazorpayError``, leaving existing ones unchanged.
    package static func wrap(_ error: any Error) -> RazorpayError {
        if let error = error as? RazorpayError { return error }
        if error is EncodingError { return .invalidRequest("could not encode the request body: \(error)") }
        return .transport(error)
    }
}
