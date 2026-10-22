import Foundation
import AsyncHTTPClient
import NIOHTTP1

/// A utility structure containing helper methods for Razorpay API operations.
/// 
/// This structure provides static utility functions for common operations like:
/// - Converting dictionary headers to HTTPHeaders
/// - Processing HTTP responses
/// - Converting query parameters to URL query strings
struct RZPRUTL {
    
    /// Converts a dictionary of string headers to HTTPHeaders.
    /// 
    /// - Parameter headers: An optional dictionary of string key-value pairs representing HTTP headers.
    /// - Returns: An HTTPHeaders object containing the converted headers.
    ///
    /// ```swift
    /// let headers = ["Content-Type": "application/json"]
    /// let httpHeaders = RZPRUTL.convertToHTTPHeaders(headers)
    /// ```
    static func convertToHTTPHeaders(_ headers: [String: String]?) -> HTTPHeaders {
        var httpHeaders = HTTPHeaders()
        headers?.forEach { key, value in
            httpHeaders.add(name: key, value: value)
        }
        return httpHeaders
    }
    
    /// Turns an HTTP response into a JSON dictionary.
    ///
    /// - Throws: ``RazorpayError/apiError(_:)`` with the HTTP status for any non-2xx response, or
    ///   for a 2xx body that contains an `error` object. Throws ``RazorpayError/invalidResponse(_:)``
    ///   if a 2xx body is not a JSON object.
    static func processResponse(_ response: RazorpayHTTPResponse) async throws -> [String: Any] {
        let status = Int(response.status.code)
        let json = try? JSONSerialization.jsonObject(with: response.body, options: []) as? [String: Any]

        guard (200..<300).contains(status) else {
            if let json, let apiError = RazorpayError.APIError(errorObject: json, statusCode: status) {
                throw RazorpayError.apiError(apiError)
            }
            throw RazorpayError.apiError(.init(statusCode: status, description: "HTTP \(status) with an unparseable error body"))
        }
        guard let json else {
            throw RazorpayError.invalidResponse("Response body is not a JSON object (HTTP \(status))")
        }
        if let apiError = RazorpayError.APIError(errorObject: json, statusCode: status) {
            throw RazorpayError.apiError(apiError)
        }
        return json
    }

    /// Serializes a JSON object into a request body.
    static func jsonBody(_ json: [String: Any]) throws -> Data {
        try JSONSerialization.data(withJSONObject: json, options: [])
    }

    /// Converts a dictionary of query parameters to a URL query string.
    /// 
    /// - Parameter queryParams: An optional dictionary of string key-value pairs representing query parameters.
    /// - Returns: A URL-encoded query string starting with "?", or an empty string if no parameters are provided.
    ///
    /// ```swift
    /// let params = ["page": "1", "limit": "10"]
    /// let queryString = RZPRUTL.convertToQueryString(params)
    /// // Returns "?page=1&limit=10"
    /// ```
    static func convertToQueryString(_ queryParams: [String: String]?) -> String {
        guard let queryParams = queryParams, !queryParams.isEmpty else { return "" }
        let queryItems = queryParams.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
        return "?" + queryItems.joined(separator: "&")
    }
    
}
