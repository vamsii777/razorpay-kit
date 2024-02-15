import Foundation
import AsyncHTTPClient
import NIOHTTP1

struct RZPRUTL {
    
    static func convertToHTTPHeaders(_ headers: [String: String]?) -> HTTPHeaders {
        var httpHeaders = HTTPHeaders()
        headers?.forEach { key, value in
            httpHeaders.add(name: key, value: value)
        }
        return httpHeaders
    }
    
    // Assuming HTTPClientResponse is a custom type in your context
    static func processResponse(_ response: HTTPClientResponse) async throws -> [String: Any] {
        // Collecting body data up to a specified limit, for example, 1 MB (1_048_576 bytes)
        let body = try await response.body.collect(upTo: 1_048_576)
        // Assuming `body` is already of type `Data` based on your usage
        let data = body // Direct use without `.data` property
        
        // TODO: Error handling and validation
        guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw RZPError.badRequestError(message: "INVALID_RESPONSE", internalErrorCode: nil, field: nil, description: nil, code: nil)
        }
        return json
    }
    
    static func convertToQueryString(_ queryParams: [String: String]?) -> String {
        guard let queryParams = queryParams, !queryParams.isEmpty else { return "" }
        let queryItems = queryParams.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
        return "?" + queryItems.joined(separator: "&")
    }
    
}
