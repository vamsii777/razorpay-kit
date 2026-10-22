import Foundation
import NIOHTTP1

/// Shared JSON coders. Razorpay sends Unix timestamps in seconds.
package enum RazorpayCoding {
    package static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    package static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    /// Decodes a response into `T`, mapping every failure to ``RazorpayError``.
    ///
    /// Non-2xx and 2xx bodies with an `error` object become ``RazorpayError/api(_:)``. Empty,
    /// garbled or incomplete 2xx bodies become ``RazorpayError/decoding(_:)``.
    package static func decode<T: Decodable>(_ type: T.Type, from response: RazorpayHTTPResponse) -> Result<T, RazorpayError> {
        let status = Int(response.status.code)
        guard (200..<300).contains(status) else {
            return .failure(.api(.init(statusCode: status, body: response.body)))
        }
        if let json = (try? JSONSerialization.jsonObject(with: response.body)) as? [String: Any],
           let apiError = RazorpayError.APIError(errorObject: json, statusCode: status) {
            return .failure(.api(apiError))
        }
        if response.body.isEmpty {
            return .failure(.decoding(.init(statusCode: status, type: String(describing: T.self), message: "empty body")))
        }
        do {
            return .success(try decoder.decode(T.self, from: response.body))
        } catch {
            return .failure(.decoding(.init(error, type: T.self, statusCode: status)))
        }
    }

    package static func encode<T: Encodable>(_ value: T) -> Result<Data, RazorpayError> {
        do { return .success(try encoder.encode(value)) } catch { return .failure(.wrap(error)) }
    }
}

extension RazorpayAPIHandler {
    /// Sends a request and decodes the response. All failures are ``RazorpayError``.
    package func result<Response: Decodable>(
        _ method: HTTPMethod,
        _ path: String,
        query: [String: String] = [:],
        body: (any Encodable & Sendable)? = nil,
        options: RequestOptions = .init(),
        as type: Response.Type = Response.self
    ) async -> Result<Response, RazorpayError> {
        var data: Data?
        if let body {
            switch RazorpayCoding.encode(body) {
            case .success(let encoded): data = encoded
            case .failure(let error): return .failure(error)
            }
        }
        do {
            let response = try await sendRequest(method: method, path: path, queryParams: query, body: data, headers: options.httpHeaders)
            return RazorpayCoding.decode(Response.self, from: response)
        } catch {
            return .failure(.wrap(error))
        }
    }

    #if compiler(>=6.0)
    /// Typed-throws wrapper over ``result(_:_:query:body:options:as:)``.
    package func perform<Response: Decodable>(
        _ method: HTTPMethod, _ path: String, query: [String: String] = [:],
        body: (any Encodable & Sendable)? = nil, options: RequestOptions = .init(),
        as type: Response.Type = Response.self
    ) async throws(RazorpayError) -> Response {
        try await result(method, path, query: query, body: body, options: options, as: type).get()
    }
    #else
    /// Throws only ``RazorpayError``.
    package func perform<Response: Decodable>(
        _ method: HTTPMethod, _ path: String, query: [String: String] = [:],
        body: (any Encodable & Sendable)? = nil, options: RequestOptions = .init(),
        as type: Response.Type = Response.self
    ) async throws -> Response {
        try await result(method, path, query: query, body: body, options: options, as: type).get()
    }
    #endif
}
