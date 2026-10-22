import Foundation

/// One page of results: Razorpay's `{"entity":"collection","count":…,"items":[…]}`.
public struct RazorpayCollection<Item: Decodable & Sendable>: Decodable, Sendable {
    public let count: Int
    public let items: [Item]

    enum CodingKeys: CodingKey { case count, items }

    public init(items: [Item]) {
        self.items = items
        self.count = items.count
    }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        items = try c.decodeIfPresent([Item].self, forKey: .items) ?? []
        count = try c.decodeIfPresent(Int.self, forKey: .count) ?? items.count
    }
}

/// Filters and paging for every `list` call.
public struct ListOptions: Sendable, Hashable {
    /// Only items created at or after this time.
    public var from: Date?
    /// Only items created at or before this time.
    public var to: Date?
    /// Items fetched per request, clamped to Razorpay's 1...100. Defaults to 100.
    public var pageSize: Int
    /// Stop after this many items in total. `nil` iterates everything.
    public var limit: Int?
    /// Extra endpoint-specific filters, for example `["receipt": "rcpt_1"]`.
    public var filters: [String: String]

    public init(from: Date? = nil, to: Date? = nil, pageSize: Int = 100, limit: Int? = nil, filters: [String: String] = [:]) {
        self.from = from
        self.to = to
        self.pageSize = pageSize
        self.limit = limit
        self.filters = filters
    }

    var clampedPageSize: Int { min(max(pageSize, 1), 100) }

    func query(count: Int, skip: Int) -> [String: String] {
        var query = filters
        if let from { query["from"] = String(Int(from.timeIntervalSince1970)) }
        if let to { query["to"] = String(Int(to.timeIntervalSince1970)) }
        query["count"] = String(count)
        query["skip"] = String(skip)
        return query
    }
}

/// Every item of a Razorpay list endpoint, fetched page by page as you iterate.
///
/// ```swift
/// for try await payment in razorpay.payments.list(.init(from: lastWeek)) {
///     print(payment.id, payment.amount)
/// }
/// let firstTen = try await razorpay.orders.list(.init(limit: 10)).collect()
/// ```
///
/// Iteration ends on an empty or short page, at ``ListOptions/limit``, or if Razorpay returns
/// the same page twice. Errors are always ``RazorpayError``.
public struct RazorpayList<Item: Decodable & Sendable>: AsyncSequence, Sendable {
    public typealias Element = Item
    package typealias PageFetcher = @Sendable (_ count: Int, _ skip: Int) async -> Result<RazorpayCollection<Item>, RazorpayError>

    let options: ListOptions
    let fetchPage: PageFetcher

    package init(options: ListOptions, fetchPage: @escaping PageFetcher) {
        self.options = options
        self.fetchPage = fetchPage
    }

    package init(handler: RazorpayAPIHandler, path: String, options: ListOptions, request: RequestOptions) {
        self.init(handler: handler, path: .success(path), options: options, request: request)
    }

    /// A list whose path may be invalid (for example an empty parent ID). The error surfaces on
    /// the first `next()`, so call sites stay `for try await item in client.x.list(...)`.
    package init(handler: RazorpayAPIHandler, path: Result<String, RazorpayError>, options: ListOptions, request: RequestOptions) {
        self.init(options: options) { count, skip in
            switch path {
            case .success(let path):
                return await handler.result(.GET, path, query: options.query(count: count, skip: skip), options: request)
            case .failure(let error):
                return .failure(error)
            }
        }
    }

    public func makeAsyncIterator() -> Iterator { Iterator(list: self) }

    public struct Iterator: AsyncIteratorProtocol {
        let list: RazorpayList
        var buffer: [Item] = []
        var skip = 0
        var yielded = 0
        var finished = false
        var lastPageFingerprint: String?

        init(list: RazorpayList) { self.list = list }

        public mutating func next() async throws -> Item? {
            if let limit = list.options.limit, yielded >= limit { return nil }
            if buffer.isEmpty {
                guard !finished else { return nil }
                let pageSize = list.options.clampedPageSize
                let wanted = list.options.limit.map { Swift.min(pageSize, $0 - yielded) } ?? pageSize
                let page = try await list.fetchPage(wanted, skip).get()
                let fingerprint = page.items.map { String(describing: $0) }.joined(separator: "\u{1F}")
                if page.items.isEmpty || (skip > 0 && fingerprint == lastPageFingerprint) {
                    finished = true
                    return nil
                }
                lastPageFingerprint = fingerprint
                finished = page.items.count < wanted
                skip += page.items.count
                buffer = page.items.reversed()
            }
            yielded += 1
            return buffer.popLast()
        }
    }

    #if compiler(>=6.0)
    /// Fetches every item (up to ``ListOptions/limit``) into an array.
    public func collect() async throws(RazorpayError) -> [Item] {
        var items: [Item] = []
        var iterator = makeAsyncIterator()
        do { while let item = try await iterator.next() { items.append(item) } } catch { throw .wrap(error) }
        return items
    }
    #else
    /// Fetches every item (up to ``ListOptions/limit``) into an array.
    public func collect() async throws -> [Item] {
        var items: [Item] = []
        var iterator = makeAsyncIterator()
        do { while let item = try await iterator.next() { items.append(item) } } catch { throw RazorpayError.wrap(error) }
        return items
    }
    #endif
}
