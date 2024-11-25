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
    
    /// Processes an HTTP response and converts the body to a dictionary.
    /// 
    /// - Parameter response: The HTTPClientResponse to process.
    /// - Returns: A dictionary containing the parsed JSON response.
    /// - Throws: `RZPError.badRequestError` if the response cannot be parsed as JSON.
    ///
    /// ```swift
    /// let response = // ... HTTP response ...
    /// let json = try await RZPRUTL.processResponse(response)
    /// ```
    static func processResponse(_ response: HTTPClientResponse) async throws -> [String: Any] {
        let body = try await response.body.collect(upTo: .max)
        let data = body
        
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw RZPError.badRequestError(message: "INVALID_RESPONSE", internalErrorCode: nil, field: nil, description: nil, code: nil)
        }
        return json
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
