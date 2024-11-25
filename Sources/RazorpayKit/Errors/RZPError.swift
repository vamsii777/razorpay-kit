import Foundation

/// A custom error type that encompasses various Razorpay API errors.
///
/// `RZPError` provides structured error information returned by the Razorpay API,
/// including error messages, codes, and additional context.
enum RZPError: Error {
    /// Indicates an error due to invalid request parameters or format.
    /// - Parameters:
    ///   - message: The main error message
    ///   - internalErrorCode: Internal error code from Razorpay
    ///   - field: The specific field that caused the error, if applicable
    ///   - description: Detailed description of the error
    ///   - code: Error code string
    case badRequestError(message: String, internalErrorCode: String?, field: String?, description: String?, code: String?)
    
    /// Indicates an internal server error from Razorpay.
    /// - Parameters:
    ///   - message: The main error message
    ///   - internalErrorCode: Internal error code from Razorpay
    ///   - field: The specific field that caused the error, if applicable
    ///   - description: Detailed description of the error
    ///   - code: Error code string
    case serverError(message: String, internalErrorCode: String?, field: String?, description: String?, code: String?)
    
    /// Indicates an error from the payment gateway.
    /// - Parameters:
    ///   - message: The main error message
    ///   - internalErrorCode: Internal error code from Razorpay
    ///   - field: The specific field that caused the error, if applicable
    ///   - description: Detailed description of the error
    ///   - code: Error code string
    case gatewayError(message: String, internalErrorCode: String?, field: String?, description: String?, code: String?)
    
    /// Indicates a failure in webhook signature verification.
    /// - Parameters:
    ///   - message: The main error message
    ///   - internalErrorCode: Internal error code from Razorpay
    ///   - field: The specific field that caused the error, if applicable
    ///   - description: Detailed description of the error
    ///   - code: Error code string
    case signatureVerificationError(message: String, internalErrorCode: String?, field: String?, description: String?, code: String?)

    /// A brief description of the error.
    ///
    /// Returns only the main error message without additional context.
    var errorDescription: String {
        switch self {
        case .badRequestError(let message, _, _, _, _),
             .serverError(let message, _, _, _, _),
             .gatewayError(let message, _, _, _, _),
             .signatureVerificationError(let message, _, _, _, _):
            return message
        }
    }
    
    /// A detailed description of the error including all available context.
    ///
    /// Returns a formatted string containing the error message, code, field, description,
    /// and error code when available. Uses "N/A" for missing values.
    var detailedError: String {
        switch self {
        case .badRequestError(message: let message, internalErrorCode: let code, field: let field, description: let description, code: let errorCode):
            return "BadRequestError: \(message), Code: \(code ?? "N/A"), Field: \(field ?? "N/A"), Description: \(description ?? "N/A"), ErrorCode: \(errorCode ?? "N/A")"
        // Add similar handling for other cases
        default:
            return errorDescription
        }
    }
}
