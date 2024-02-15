import Foundation
import NIO
import NIOFoundationCompat
import NIOHTTP1
import AsyncHTTPClient

public enum Environment {
    case production
    case sandbox
    
    var baseUrl: String {
        switch self {
        case .production:
            return APIConstants.baseURL
        case .sandbox:
            return APIConstants.baseURL
        }
    }
}

extension HTTPClientRequest.Body {
    public static func string(_ string: String) -> Self {
        .bytes(.init(string: string))
    }
    
    public static func data(_ data: Data) -> Self {
        .bytes(.init(data: data))
    }

    public static func json(_ json: [String: Any]) throws -> Self {
        .bytes(.init(data: try JSONSerialization.data(withJSONObject: json, options: [])))
    }
}

struct RazorpayAPIHandler {
    private let httpClient: HTTPClient
    private let environment: Environment
    private let key: String
    private let secret: String
    
    public init(httpClient: HTTPClient, key: String, secret: String, environment: Environment) {
        self.httpClient = httpClient
        self.key = key
        self.secret = secret
        self.environment = environment
    }
    
    private func authorizationHeader() -> String {
        let credentials = "\(key):\(secret)".data(using: .utf8)!.base64EncodedString()
        return "Basic \(credentials)"
    }
    
    public func sendRequest(method: HTTPMethod,
                            path: String,
                            queryParams: [String: String]? = nil,
                            body: HTTPClientRequest.Body? = nil,
                            headers: HTTPHeaders) async throws -> HTTPClientResponse {
        
        let queryString = RZPRUTL.convertToQueryString(queryParams)
        let url = environment.baseUrl + path + queryString
        
        var requestHeaders: HTTPHeaders = ["Authorization": authorizationHeader(), "Content-Type": "application/json",
                                           "Accept": "application/json"]
        headers.forEach { requestHeaders.add(name: $0.name, value: $0.value) }

        var request = HTTPClientRequest(url: url)
        request.method = method
        request.headers = requestHeaders
        request.body = body
        
        let response = try await httpClient.execute(request, timeout: .seconds(60))
        return response
    }
}
