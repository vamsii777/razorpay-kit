import Foundation

/// An error returned by the Razorpay API or raised while handling its response.
///
/// Any non-2xx response throws ``apiError(_:)`` with the HTTP status and Razorpay's error fields.
/// If a non-2xx body cannot be parsed, you still get ``apiError(_:)``, with only
/// ``APIError/statusCode`` and a generic description set.
/// See https://razorpay.com/docs/api/errors/.
///
/// ## Topics
/// ### Error Cases
/// - ``invalidResponse(_:)``
/// - ``apiError(_:)``
///
/// ### Inspecting Errors
/// - ``statusCode``
/// - ``isInvalidCredentials``
/// - ``isInvalidAmount``
/// - ``isMissingRequiredField``
public enum RazorpayError: Error, LocalizedError, Sendable {
    /// A successful (2xx) response could not be decoded.
    case invalidResponse(String)

    /// The API returned an error, either as a non-2xx status or as an `error` object.
    case apiError(APIError)

    /// The error object Razorpay returns, plus the HTTP status.
    ///
    /// Fields Razorpay did not send are `nil`. No defaults are filled in.
    /// See https://razorpay.com/docs/api/errors/.
    public struct APIError: Sendable, Codable, Equatable {
        /// The HTTP status of the response, or `nil` for errors raised on the client side.
        public let statusCode: Int?

        /// The error code, for example `BAD_REQUEST_ERROR`. Codes this SDK does not know are kept as-is.
        public let code: ErrorCode?

        /// A readable description of the error.
        public let description: String

        /// Where the error came from, for example `business`.
        public let source: String?

        /// The payment step where the error happened, for example `payment_initiation`.
        public let step: String?

        /// Why the error happened, for example `input_validation_failed`.
        public let reason: String?

        /// The request field that caused the error, if any.
        public let field: String?

        /// Extra metadata about the error.
        public let metadata: [String: String]?

        /// A Razorpay error code. This type is open: codes this SDK does not know are kept in ``rawValue``.
        public struct ErrorCode: RawRepresentable, Hashable, Sendable, Codable, CustomStringConvertible {
            /// The code exactly as Razorpay sent it.
            public let rawValue: String

            /// Creates a code from its raw value.
            public init(rawValue: String) { self.rawValue = rawValue }

            /// Creates a code from a single-value container holding the raw string.
            public init(from decoder: any Decoder) throws {
                self.rawValue = try decoder.singleValueContainer().decode(String.self)
            }

            /// Encodes the raw string.
            public func encode(to encoder: any Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(rawValue)
            }

            public var description: String { rawValue }

            /// Invalid request parameters.
            public static let badRequestError = ErrorCode(rawValue: "BAD_REQUEST_ERROR")
            /// An error from the payment gateway.
            public static let gatewayError = ErrorCode(rawValue: "GATEWAY_ERROR")
            /// An internal Razorpay server error.
            public static let serverError = ErrorCode(rawValue: "SERVER_ERROR")
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
            guard let errorDict = response["error"] as? [String: Any] else { return nil }
            self.init(
                statusCode: statusCode,
                code: (errorDict["code"] as? String).map(ErrorCode.init(rawValue:)),
                description: errorDict["description"] as? String
                    ?? statusCode.map { "HTTP \($0)" } ?? "Unknown Razorpay error",
                source: errorDict["source"] as? String,
                step: errorDict["step"] as? String,
                reason: errorDict["reason"] as? String,
                field: errorDict["field"] as? String,
                metadata: (errorDict["metadata"] as? [String: Any])?.mapValues { "\($0)" }
            )
        }
    }

    /// The HTTP status of the failed response, if there was one.
    public var statusCode: Int? {
        if case .apiError(let error) = self { return error.statusCode }
        return nil
    }

    public var errorDescription: String? {
        switch self {
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .apiError(let error):
            var text = ""
            if let status = error.statusCode { text += "HTTP \(status) " }
            text += "[\(error.code?.rawValue ?? "unknown")] \(error.description)"
            if let field = error.field { text += " (Field: \(field))" }
            if let reason = error.reason { text += " - \(reason)" }
            return text
        }
    }

    /// `true` when Razorpay rejected the API key or secret (HTTP 401).
    public var isInvalidCredentials: Bool {
        guard case .apiError(let error) = self else { return false }
        return error.statusCode == 401
            || (error.code == .badRequestError && error.description.contains("API <key/secret> provided is invalid"))
    }

    /// `true` when the error is about the `amount` field.
    public var isInvalidAmount: Bool {
        guard case .apiError(let error) = self else { return false }
        return error.code == .badRequestError && error.field == "amount"
    }

    /// `true` when request validation failed, for example because a required field is missing.
    public var isMissingRequiredField: Bool {
        guard case .apiError(let error) = self else { return false }
        return error.code == .badRequestError && error.reason == "input_validation_failed"
    }

    /// `true` when the payment ID failed validation.
    public var isValidPaymentId: Bool {
        guard case .apiError(let error) = self else { return false }
        return error.code == .badRequestError && error.field == "id" && error.reason == "input_validation_failed"
    }
}
