import Foundation

/// A bank account as Razorpay returns it in customers, virtual accounts and fund accounts.
public struct BankAccount: Sendable, Hashable, Codable {
    public typealias ID = RazorpayID<BankAccount>

    /// `ba_…`. Absent when the account is embedded without an ID (for example a payer).
    public let id: ID?
    public let ifsc: String?
    public let bankName: String?
    /// The account holder's (beneficiary's) name.
    public let name: String?
    public let accountNumber: String?
    public let notes: Notes

    public init(id: ID? = nil, ifsc: String? = nil, bankName: String? = nil, name: String? = nil,
                accountNumber: String? = nil, notes: Notes = [:]) {
        self.id = id; self.ifsc = ifsc; self.bankName = bankName; self.name = name
        self.accountNumber = accountNumber; self.notes = notes
    }

    enum CodingKeys: String, CodingKey { case id, ifsc, name, notes, bankName = "bank_name", accountNumber = "account_number" }

    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(ID.self, forKey: .id)
        ifsc = try c.decodeIfPresent(String.self, forKey: .ifsc)
        bankName = try c.decodeIfPresent(String.self, forKey: .bankName)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        // Account numbers can arrive as JSON numbers; keep them as strings (leading zeros matter when sent as strings).
        accountNumber = try (try? c.decodeIfPresent(String.self, forKey: .accountNumber)) ?? c.decodeIfPresent(Int.self, forKey: .accountNumber).map(String.init)
        notes = try NotesCoding.decode(c, .notes)
    }
}

/// A UPI ID as Razorpay returns it: `username@handle`.
public struct VPAAddress: Sendable, Hashable, Codable {
    public let username: String?
    public let handle: String?
    public let address: String?

    public init(username: String? = nil, handle: String? = nil, address: String? = nil) {
        self.username = username; self.handle = handle; self.address = address
    }

    /// `address`, or `username@handle` when only the parts are present.
    public var fullAddress: String? {
        address ?? username.flatMap { u in handle.map { "\(u)@\($0)" } }
    }
}
