import Foundation

// Define a custom error type that encompasses various Razorpay errors.
enum RZPError: Error {
    case badRequestError(message: String, internalErrorCode: String?, field: String?, description: String?, code: String?)
    case serverError(message: String, internalErrorCode: String?, field: String?, description: String?, code: String?)
    case gatewayError(message: String, internalErrorCode: String?, field: String?, description: String?, code: String?)
    case signatureVerificationError(message: String, internalErrorCode: String?, field: String?, description: String?, code: String?)

    // Custom string representation of the error
    var errorDescription: String {
        switch self {
        case .badRequestError(let message, _, _, _, _),
             .serverError(let message, _, _, _, _),
             .gatewayError(let message, _, _, _, _),
             .signatureVerificationError(let message, _, _, _, _):
            return message
        }
    }
    
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

