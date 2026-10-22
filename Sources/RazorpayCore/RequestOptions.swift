import NIOHTTP1

/// Per-request settings shared by every typed API.
///
/// ```swift
/// try await razorpay.payments.capture(id, amount: .inr(paise: 5000),
///                                     options: .init(idempotencyKey: "cap-\(id)"))
/// ```
public struct RequestOptions: Sendable, Equatable {
    /// Sent as `X-Razorpay-Idempotency-Key`. Reuse the same key when retrying.
    public var idempotencyKey: String?
    /// Sent as `X-Razorpay-Account` to act on behalf of a linked (Route/partner) account.
    public var accountID: String?
    /// Any extra headers. They override SDK defaults except `Authorization`.
    public var headers: [String: String]

    public init(idempotencyKey: String? = nil, accountID: String? = nil, headers: [String: String] = [:]) {
        self.idempotencyKey = idempotencyKey
        self.accountID = accountID
        self.headers = headers
    }

    var httpHeaders: HTTPHeaders {
        var result = HTTPHeaders()
        for (name, value) in headers.sorted(by: { $0.key < $1.key }) where name.lowercased() != "authorization" {
            result.replaceOrAdd(name: name, value: value)
        }
        if let idempotencyKey { result.replaceOrAdd(name: "X-Razorpay-Idempotency-Key", value: idempotencyKey) }
        if let accountID { result.replaceOrAdd(name: "X-Razorpay-Account", value: accountID) }
        return result
    }
}
