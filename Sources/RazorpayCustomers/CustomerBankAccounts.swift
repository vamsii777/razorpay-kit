import Foundation
import RazorpayCore

#if compiler(>=6.0)
extension RazorpayClient.Customers {
    /// Adds a bank account to a customer (for refunds to bank, eMandate and payouts).
    public func addBankAccount(_ account: Customer.NewBankAccount, to customer: Customer.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> BankAccount {
        try await handler.perform(.POST, "/v1/customers/\(customer.pathComponent().get())/bank_account", body: account.validate().get(), options: options)
    }

    /// Removes a bank account from a customer.
    public func deleteBankAccount(_ id: BankAccount.ID, of customer: Customer.ID, options: RequestOptions = .init()) async throws(RazorpayError) {
        let _: EmptyResponse = try await handler.perform(.DELETE, "/v1/customers/\(customer.pathComponent().get())/bank_account/\(id.pathComponent().get())", options: options)
    }
}
#else
extension RazorpayClient.Customers {
    /// Adds a bank account to a customer (for refunds to bank, eMandate and payouts).
    public func addBankAccount(_ account: Customer.NewBankAccount, to customer: Customer.ID, options: RequestOptions = .init()) async throws -> BankAccount {
        try await handler.perform(.POST, "/v1/customers/\(customer.pathComponent().get())/bank_account", body: account.validate().get(), options: options)
    }

    /// Removes a bank account from a customer.
    public func deleteBankAccount(_ id: BankAccount.ID, of customer: Customer.ID, options: RequestOptions = .init()) async throws {
        let _: EmptyResponse = try await handler.perform(.DELETE, "/v1/customers/\(customer.pathComponent().get())/bank_account/\(id.pathComponent().get())", options: options)
    }
}
#endif

extension Customer {
    /// `POST /v1/customers/:id/bank_account`.
    public struct NewBankAccount: Sendable, Hashable, Encodable {
        public var ifsc: String
        public var accountNumber: String
        public var beneficiaryName: String
        public var beneficiaryEmail: String?
        public var beneficiaryMobile: String?
        public var address: Address?

        /// The beneficiary's postal address.
        public struct Address: Sendable, Hashable {
            public var line1: String
            public var line2: String?
            public var city: String?
            public var state: String?
            public var country: String?
            public var pin: String?
            public init(line1: String, line2: String? = nil, city: String? = nil, state: String? = nil, country: String? = nil, pin: String? = nil) {
                self.line1 = line1; self.line2 = line2; self.city = city; self.state = state; self.country = country; self.pin = pin
            }
        }

        public init(ifsc: String, accountNumber: String, beneficiaryName: String, beneficiaryEmail: String? = nil,
                    beneficiaryMobile: String? = nil, address: Address? = nil) {
            self.ifsc = ifsc; self.accountNumber = accountNumber; self.beneficiaryName = beneficiaryName
            self.beneficiaryEmail = beneficiaryEmail; self.beneficiaryMobile = beneficiaryMobile; self.address = address
        }

        enum CodingKeys: String, CodingKey {
            case ifsc = "ifsc_code", accountNumber = "account_number", beneficiaryName = "beneficiary_name"
            case beneficiaryEmail = "beneficiary_email", beneficiaryMobile = "beneficiary_mobile"
            case line1 = "beneficiary_address1", line2 = "beneficiary_address2", city = "beneficiary_city"
            case state = "beneficiary_state", country = "beneficiary_country", pin = "beneficiary_pin"
        }

        public func encode(to encoder: any Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(ifsc.uppercased(), forKey: .ifsc)
            try c.encode(accountNumber, forKey: .accountNumber)
            try c.encode(beneficiaryName, forKey: .beneficiaryName)
            try c.encodeIfPresent(beneficiaryEmail, forKey: .beneficiaryEmail)
            try c.encodeIfPresent(beneficiaryMobile, forKey: .beneficiaryMobile)
            if let a = address {
                try c.encode(a.line1, forKey: .line1)
                try c.encodeIfPresent(a.line2, forKey: .line2)
                try c.encodeIfPresent(a.city, forKey: .city)
                try c.encodeIfPresent(a.state, forKey: .state)
                try c.encodeIfPresent(a.country, forKey: .country)
                try c.encodeIfPresent(a.pin, forKey: .pin)
            }
        }

        func validate() -> Result<Self, RazorpayError> {
            guard ifsc.count == 11, ifsc.allSatisfy({ $0.isLetter || $0.isNumber }) else { return .failure(.invalidRequest("IFSC must be 11 letters or digits")) }
            guard !accountNumber.isEmpty, accountNumber.allSatisfy(\.isNumber) else { return .failure(.invalidRequest("account number must be digits")) }
            guard !beneficiaryName.trimmingCharacters(in: .whitespaces).isEmpty else { return .failure(.invalidRequest("beneficiary name is empty")) }
            return .success(self)
        }
    }
}
