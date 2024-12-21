import Foundation
import NIOHTTP1

public protocol RazorpayAPIRoute: Sendable {
    var headers: HTTPHeaders { get set }
    
    /// Headers to send with the request.
    mutating func addHeaders(_ headers: HTTPHeaders) -> Self
}

extension RazorpayAPIRoute {
    public mutating func addHeaders(_ headers: HTTPHeaders) -> Self {
        headers.forEach { self.headers.replaceOrAdd(name: $0.name, value: $0.value) }
        return self
    }
}
