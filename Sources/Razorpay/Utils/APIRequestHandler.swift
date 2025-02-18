import Foundation
import RazorpayKit

/// Utility for handling Razorpay API requests and responses
internal enum APIRequestHandler {
    
    /// Executes an API request and handles common error cases
    static func execute<T>(
        operation: @escaping () async throws -> [String: Any]
    ) async throws -> T where T: RazorpayResponse {
        do {
            let response = try await operation()
            
            // If response is an error response, throw it directly
            if let errorDict = response["error"] as? [String: Any] {
                // Create APIError manually to avoid decoding issues
                let code = (errorDict["code"] as? String).flatMap { 
                    RazorpayError.APIError.ErrorCode(rawValue: $0) 
                } ?? .unknown
                let description = errorDict["description"] as? String ?? "Unknown error"
                let source = errorDict["source"] as? String ?? "business"
                let step = errorDict["step"] as? String ?? "payment_initiation"
                let reason = errorDict["reason"] as? String ?? "unknown"
                let field = errorDict["field"] as? String
                let metadata = (errorDict["metadata"] as? [String: Any])?.compactMapValues { "\($0)" } ?? [:]
                
                let error = RazorpayError.APIError(
                    code: code,
                    description: description,
                    source: source,
                    step: step,
                    reason: reason,
                    field: field,
                    metadata: metadata
                )

                throw RazorpayError.apiError(error)
            }
            
            return try T(response: response)
        } catch let error as RazorpayError {
            throw error
        } catch {
            throw RazorpayError.invalidResponse(error.localizedDescription)
        }
    }
    
    /// Validates that a value meets minimum requirements
    static func validateMinimum<T: Comparable>(
        _ value: T,
        minimum: T,
        field: String,
        message: String
    ) throws {
        guard value >= minimum else {
            throw RazorpayError.apiError(
                RazorpayError.APIError(
                    code: .badRequestError,
                    description: message,
                    field: field
                )
            )
        }
    }
}

/// Protocol for Razorpay API response models
public protocol RazorpayResponse: Codable {
    /// Initialize from raw API response dictionary
    /// - Parameter response: Dictionary containing the API response data
    /// - Throws: RazorpayError if the response is invalid or cannot be parsed
    init(response: [String: Any]) throws
}

/// Default implementation for RazorpayResponse
public extension RazorpayResponse {
    /// Default implementation that converts dictionary to JSON and uses Codable
    init(response: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970 // Handle Unix timestamps
        self = try decoder.decode(Self.self, from: data)
    }
}

/// Structure to represent Razorpay API error responses in a Sendable way
private struct RazorpayKitErrorResponse: Sendable {
    let code: String
    let description: String
    let source: String
    let step: String
    let reason: String
    let field: String?
    let metadata: [String: String]
}

/// Error type for RazorpayKit specific errors
private enum RazorpayKitError: Error, Sendable {
    case apiError(RazorpayKitErrorResponse)
} 
