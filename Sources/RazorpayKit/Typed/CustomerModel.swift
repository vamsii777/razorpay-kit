import Foundation

/// A saved customer. See https://razorpay.com/docs/api/customers/.
public struct Customer: Sendable, Hashable, Identifiable, Decodable {
    public typealias ID = RazorpayID<Customer>

    public let id: ID
    public let name: String?
    public let email: String?
    public let contact: String?
    public let gstin: String?
    public let notes: Notes
    public let createdAt: Date

    /// The body for ``RazorpayClient/Customers/create(_:options:)`` and `update`.
    public struct Create: Sendable, Hashable, Encodable {
        public var name: String?
        public var email: String?
        public var contact: String?
        public var gstin: String?
        public var notes: Notes
        /// When `true` (the default), creating an existing customer returns it instead of failing.
        public var returnExisting: Bool

        public init(name: String? = nil, email: String? = nil, contact: String? = nil, gstin: String? = nil, notes: Notes = [:], returnExisting: Bool = true) {
            self.name = name
            self.email = email
            self.contact = contact
            self.gstin = gstin
            self.notes = notes
            self.returnExisting = returnExisting
        }

        enum CodingKeys: String, CodingKey { case name, email, contact, gstin, notes, failExisting = "fail_existing" }
        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encodeIfPresent(name, forKey: .name)
            try c.encodeIfPresent(email, forKey: .email)
            try c.encodeIfPresent(contact, forKey: .contact)
            try c.encodeIfPresent(gstin, forKey: .gstin)
            if !notes.isEmpty { try c.encode(notes, forKey: .notes) }
            try c.encode(returnExisting ? "0" : "1", forKey: .failExisting)
        }
    }

    /// Fields to change. Only non-nil fields are sent.
    public struct Update: Sendable, Hashable, Encodable {
        public var name: String?
        public var email: String?
        public var contact: String?
        public init(name: String? = nil, email: String? = nil, contact: String? = nil) {
            self.name = name
            self.email = email
            self.contact = contact
        }
    }

    enum CodingKeys: String, CodingKey { case id, name, email, contact, gstin, notes, createdAt = "created_at" }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ID.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        email = try c.decodeIfPresent(String.self, forKey: .email)
        contact = try c.decodeIfPresent(String.self, forKey: .contact)
        gstin = try c.decodeIfPresent(String.self, forKey: .gstin)
        notes = try NotesCoding.decode(c, .notes)
        createdAt = try c.decode(Date.self, forKey: .createdAt)
    }
}
