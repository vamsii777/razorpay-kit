import Foundation

/// Any JSON value. Used by ``RazorpayClient/raw`` and for payload parts this SDK does not model.
///
/// ```swift
/// let plan = try await razorpay.raw.get("/v1/plans/plan_123")
/// plan["item"]?["amount"]?.intValue
/// ```
public enum JSONValue: Hashable, Sendable, Codable, ExpressibleByStringLiteral, ExpressibleByIntegerLiteral,
    ExpressibleByBooleanLiteral, ExpressibleByArrayLiteral, ExpressibleByDictionaryLiteral, ExpressibleByNilLiteral,
    ExpressibleByFloatLiteral {
    case null
    case bool(Bool)
    case int(Int)
    case double(Double)
    case string(String)
    case array([JSONValue])
    case object([String: JSONValue])

    public init(stringLiteral value: String) { self = .string(value) }
    public init(integerLiteral value: Int) { self = .int(value) }
    public init(floatLiteral value: Double) { self = .double(value) }
    public init(booleanLiteral value: Bool) { self = .bool(value) }
    public init(arrayLiteral elements: JSONValue...) { self = .array(elements) }
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = .object(Dictionary(elements, uniquingKeysWith: { _, last in last }))
    }
    public init(nilLiteral: ()) { self = .null }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { self = .null }
        else if let value = try? container.decode(Bool.self) { self = .bool(value) }
        else if let value = try? container.decode(Int.self) { self = .int(value) }
        else if let value = try? container.decode(Double.self) { self = .double(value) }
        else if let value = try? container.decode(String.self) { self = .string(value) }
        else if let value = try? container.decode([JSONValue].self) { self = .array(value) }
        else { self = .object(try container.decode([String: JSONValue].self)) }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .null: try container.encodeNil()
        case .bool(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        case .object(let value): try container.encode(value)
        }
    }

    /// The member at `key` for objects, otherwise `nil`.
    public subscript(key: String) -> JSONValue? {
        if case .object(let object) = self { return object[key] }
        return nil
    }

    /// The element at `index` for arrays, otherwise `nil`. Out-of-range indexes return `nil`.
    public subscript(index: Int) -> JSONValue? {
        if case .array(let array) = self, array.indices.contains(index) { return array[index] }
        return nil
    }

    public var stringValue: String? { if case .string(let v) = self { return v }; return nil }
    public var intValue: Int? {
        switch self {
        case .int(let v): return v
        case .double(let v) where v.rounded() == v && abs(v) < 9e15: return Int(v)
        default: return nil
        }
    }
    public var doubleValue: Double? {
        switch self { case .double(let v): return v; case .int(let v): return Double(v); default: return nil }
    }
    public var boolValue: Bool? { if case .bool(let v) = self { return v }; return nil }
    public var arrayValue: [JSONValue]? { if case .array(let v) = self { return v }; return nil }
    public var objectValue: [String: JSONValue]? { if case .object(let v) = self { return v }; return nil }
    public var isNull: Bool { self == .null }

    /// Decodes this value into a model, for example `try value.decode(as: Payment.self)`.
    public func decode<T: Decodable>(as type: T.Type) throws -> T {
        try RazorpayCoding.decoder.decode(T.self, from: RazorpayCoding.encoder.encode(self))
    }
}

/// Razorpay `notes`: up to 15 string key-value pairs.
///
/// Razorpay sends an empty `notes` as `[]` instead of `{}`, and sometimes sends non-string
/// values. Both decode cleanly here.
public typealias Notes = [String: String]

package enum NotesCoding {
    package static func decode<K>(_ container: KeyedDecodingContainer<K>, _ key: K) throws -> Notes {
        guard let value = try container.decodeIfPresent(JSONValue.self, forKey: key) else { return [:] }
        switch value {
        case .object(let object):
            return object.compactMapValues { value in
                switch value {
                case .string(let s): return s
                case .int(let i): return String(i)
                case .double(let d): return String(d)
                case .bool(let b): return String(b)
                case .null, .array, .object: return nil
                }
            }
        default:
            return [:]
        }
    }
}
