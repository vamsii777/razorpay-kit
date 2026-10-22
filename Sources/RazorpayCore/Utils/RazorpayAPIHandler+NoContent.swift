import Foundation
import NIOHTTP1

extension RazorpayAPIHandler {
    /// Sends a request whose success response carries nothing useful (`[]`, `{}` or an empty body),
    /// such as a delete. Non-2xx responses and error objects still fail with ``RazorpayError``.
    package func resultIgnoringBody(
        _ method: HTTPMethod, _ path: String, query: [String: String] = [:],
        body: (any Encodable & Sendable)? = nil, options: RequestOptions = .init()
    ) async -> Result<Void, RazorpayError> {
        var data: Data?
        if let body {
            switch RazorpayCoding.encode(body) {
            case .success(let encoded): data = encoded
            case .failure(let error): return .failure(error)
            }
        }
        do {
            let response = try await sendRequest(method: method, path: path, queryParams: query, body: data, headers: options.httpHeaders)
            if (200..<300).contains(Int(response.status.code)), response.body.isEmpty { return .success(()) }
            return RazorpayCoding.decode(JSONValue.self, from: response).map { _ in () }
        } catch {
            return .failure(.wrap(error))
        }
    }
}
