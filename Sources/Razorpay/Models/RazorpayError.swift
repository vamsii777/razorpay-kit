import Foundation

/// Represents errors that can occur when interacting with the Razorpay API
///
/// This enum encapsulates different types of errors that may occur during API operations:
/// - Invalid response format or missing fields
/// - API-specific error responses with detailed information
///
/// ## Topics
/// ### Error Cases
/// - ``invalidResponse(_:)``
/// - ``apiError(_:)``
///
/// ### Error Properties
/// - ``isInvalidCredentials``
/// - ``isInvalidAmount``
/// - ``isMissingRequiredField``
public enum RazorpayError: LocalizedError {
    /// Invalid response format or missing required fields
    case invalidResponse(String)
    
    /// API returned an error response
    case apiError(APIError)
    
    /// Represents the structure of Razorpay API error responses
    ///
    /// This struct contains detailed information about API errors including:
    /// - Error code and description
    /// - Source and step where error occurred
    /// - Reason for the error
    /// - Optional field that caused the error
    /// - Additional metadata
    public struct APIError: Sendable, Codable {
        /// The type of error that occurred
        public let code: ErrorCode?
        
        /// Detailed description of the error
        public let description: String
        
        /// Source of the error (e.g. "business")
        public let source: String?
        
        /// Step where error occurred (e.g. "payment_initiation")
        public let step: String?
        
        /// Reason for the error (e.g. "input_validation_failed")
        public let reason: String?
        
        /// Optional field that caused the error
        public let field: String?
        
        /// Additional metadata about the error
        public let metadata: [String: String]?
        
        /// Represents different types of API error codes
        @frozen
        public enum ErrorCode: String, Sendable, Codable {
            /// Error due to invalid request parameters
            case badRequestError = "BAD_REQUEST_ERROR"
            
            /// Error from payment gateway
            case gatewayError = "GATEWAY_ERROR"
            
            /// Internal server error
            case serverError = "SERVER_ERROR"
            
            /// Unknown error type
            case unknown
            
            /// HTTP status code associated with this error
            public var httpStatus: Int {
                switch self {
                case .badRequestError: return 400
                case .serverError: return 500
                case .gatewayError: return 502
                case .unknown: return 400
                }
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case code
            case description
            case source
            case step
            case reason
            case field
            case metadata
        }
        
        public init(
            code: ErrorCode? = nil,
            description: String,
            source: String? = "business",
            step: String? = "payment_initiation",
            reason: String? = "input_validation_failed",
            field: String? = nil,
            metadata: [String: String]? = nil
        ) {
            self.code = code
            self.description = description
            self.source = source
            self.step = step
            self.reason = reason
            self.field = field
            self.metadata = metadata
        }
        
        init(response: [String: Any]) throws {
            guard let errorDict = response["error"] as? [String: Any] else {
                throw RazorpayError.invalidResponse("Missing error object in response")
            }
            
            guard let description = errorDict["description"] as? String else {
                throw RazorpayError.invalidResponse("Missing error description")
            }
            
            let codeString = errorDict["code"] as? String ?? ""
            self.code = ErrorCode(rawValue: codeString) ?? .unknown
            self.description = description
            self.source = errorDict["source"] as? String ?? "business"
            self.step = errorDict["step"] as? String ?? "payment_initiation"
            self.reason = errorDict["reason"] as? String ?? "input_validation_failed"
            self.field = errorDict["field"] as? String
            
            if let metadata = errorDict["metadata"] as? [String: Any] {
                self.metadata = metadata.compactMapValues { "\($0)" }
            } else {
                self.metadata = [:]
            }
        }
    }
    
    public var errorDescription: String? {
        switch self {
        case .invalidResponse(let message):
            return "Invalid response: \(message)"
        case .apiError(let error):
            var description = "[\(error.code?.rawValue ?? "unknown")] \(error.description)"
            if let field = error.field {
                description += " (Field: \(field))"
            }
            description += " - \(error.reason ?? "unknown")"
            return description
        }
    }
    
    /// Returns true if the error is due to invalid API credentials
    public var isInvalidCredentials: Bool {
        if case .apiError(let error) = self {
            return error.code == .badRequestError && 
                   error.description.contains("API <key/secret> provided is invalid")
        }
        return false
    }
    
    /// Returns true if the error is due to amount validation
    public var isInvalidAmount: Bool {
        if case .apiError(let error) = self {
            return error.code == .badRequestError && 
                   error.field == "amount"
        }
        return false
    }
    
    /// Returns true if the error is due to missing required fields
    public var isMissingRequiredField: Bool {
        if case .apiError(let error) = self {
            return error.code == .badRequestError && 
                   error.reason == "input_validation_failed"
        }
        return false
    }

    public var isValidPaymentId: Bool {
         if case .apiError(let error) = self {
            return error.code == .badRequestError && 
                   error.field == "id" &&
                   error.reason == "input_validation_failed"
        }
        return false
    }
} 
