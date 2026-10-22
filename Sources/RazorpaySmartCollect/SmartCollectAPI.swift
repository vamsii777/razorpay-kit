import Foundation
import RazorpayCore
import RazorpayPayments

#if compiler(>=6.0)
extension RazorpayClient.VirtualAccounts {
    /// Creates a virtual account.
    public func create(_ account: VirtualAccount.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> VirtualAccount {
        try await handler.perform(.POST, "/v1/virtual_accounts", body: account.validate().get(), options: options)
    }

    /// Fetches a virtual account.
    public func fetch(_ id: VirtualAccount.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> VirtualAccount {
        try await handler.perform(.GET, "/v1/virtual_accounts/\(id.pathComponent().get())", options: options)
    }

    /// Lists virtual accounts, fetching pages lazily.
    public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<VirtualAccount> {
        RazorpayList(handler: handler, path: "/v1/virtual_accounts", options: list, request: options)
    }

    /// Lists the payments made into a virtual account.
    public func payments(of id: VirtualAccount.ID, _ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Payment> {
        RazorpayList(handler: handler, path: id.pathComponent().map { "/v1/virtual_accounts/\($0)/payments" }, options: list, request: options)
    }

    /// Closes a virtual account so it stops accepting payments.
    public func close(_ id: VirtualAccount.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> VirtualAccount {
        try await handler.perform(.POST, "/v1/virtual_accounts/\(id.pathComponent().get())/close", options: options)
    }

    /// Adds receivers (for example a UPI ID) to an existing virtual account.
    public func addReceivers(_ kinds: Set<VirtualAccount.Receiver.Kind>, vpaDescriptor: String? = nil, to id: VirtualAccount.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> VirtualAccount {
        guard !kinds.isEmpty else { throw RazorpayError.invalidRequest("at least one receiver type is required") }
        return try await handler.perform(.POST, "/v1/virtual_accounts/\(id.pathComponent().get())/receivers", body: ReceiversBody(kinds, vpaDescriptor), options: options)
    }

    /// Adds an allowed (TPV) payer bank account.
    public func addAllowedPayer(_ bankAccount: BankAccount, to id: VirtualAccount.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> VirtualAccount {
        try await handler.perform(.POST, "/v1/virtual_accounts/\(id.pathComponent().get())/allowed_payers", body: VirtualAccount.AllowedPayer(bankAccount: bankAccount), options: options)
    }

    /// Removes an allowed payer. Razorpay returns an empty body.
    public func removeAllowedPayer(_ payerID: String, from id: VirtualAccount.ID, options: RequestOptions = .init()) async throws(RazorpayError) {
        let payer = try RazorpayID<VirtualAccount.AllowedPayer>(payerID).pathComponent().get()
        let _: EmptyResponse = try await handler.perform(.DELETE, "/v1/virtual_accounts/\(id.pathComponent().get())/allowed_payers/\(payer)", options: options)
    }

    /// How a bank-transfer payment reached the account (payer bank, UTR).
    public func bankTransfer(for payment: PaymentID, options: RequestOptions = .init()) async throws(RazorpayError) -> BankTransfer {
        try await handler.perform(.GET, "/v1/payments/\(payment.pathComponent().get())/bank_transfer", options: options)
    }
}

extension RazorpayClient.FundAccounts {
    /// Creates a fund account for a customer.
    public func create(for customer: CustomerID, _ destination: FundAccount.Destination, options: RequestOptions = .init()) async throws(RazorpayError) -> FundAccount {
        try await handler.perform(.POST, "/v1/fund_accounts", body: FundAccountBody(customer: customer, destination: destination).validate().get(), options: options)
    }

    /// Lists a customer's fund accounts.
    public func list(for customer: CustomerID, options: RequestOptions = .init()) async throws(RazorpayError) -> [FundAccount] {
        let id = try customer.pathComponent().get()
        let page: RazorpayCollection<FundAccount> = try await handler.perform(.GET, "/v1/fund_accounts", query: ["customer_id": id], options: options)
        return page.items
    }
}
#else
extension RazorpayClient.VirtualAccounts {
    /// Creates a virtual account.
    public func create(_ account: VirtualAccount.Create, options: RequestOptions = .init()) async throws -> VirtualAccount {
        try await handler.perform(.POST, "/v1/virtual_accounts", body: account.validate().get(), options: options)
    }

    /// Fetches a virtual account.
    public func fetch(_ id: VirtualAccount.ID, options: RequestOptions = .init()) async throws -> VirtualAccount {
        try await handler.perform(.GET, "/v1/virtual_accounts/\(id.pathComponent().get())", options: options)
    }

    /// Lists virtual accounts, fetching pages lazily.
    public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<VirtualAccount> {
        RazorpayList(handler: handler, path: "/v1/virtual_accounts", options: list, request: options)
    }

    /// Lists the payments made into a virtual account.
    public func payments(of id: VirtualAccount.ID, _ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Payment> {
        RazorpayList(handler: handler, path: id.pathComponent().map { "/v1/virtual_accounts/\($0)/payments" }, options: list, request: options)
    }

    /// Closes a virtual account so it stops accepting payments.
    public func close(_ id: VirtualAccount.ID, options: RequestOptions = .init()) async throws -> VirtualAccount {
        try await handler.perform(.POST, "/v1/virtual_accounts/\(id.pathComponent().get())/close", options: options)
    }

    /// Adds receivers (for example a UPI ID) to an existing virtual account.
    public func addReceivers(_ kinds: Set<VirtualAccount.Receiver.Kind>, vpaDescriptor: String? = nil, to id: VirtualAccount.ID, options: RequestOptions = .init()) async throws -> VirtualAccount {
        guard !kinds.isEmpty else { throw RazorpayError.invalidRequest("at least one receiver type is required") }
        return try await handler.perform(.POST, "/v1/virtual_accounts/\(id.pathComponent().get())/receivers", body: ReceiversBody(kinds, vpaDescriptor), options: options)
    }

    /// Adds an allowed (TPV) payer bank account.
    public func addAllowedPayer(_ bankAccount: BankAccount, to id: VirtualAccount.ID, options: RequestOptions = .init()) async throws -> VirtualAccount {
        try await handler.perform(.POST, "/v1/virtual_accounts/\(id.pathComponent().get())/allowed_payers", body: VirtualAccount.AllowedPayer(bankAccount: bankAccount), options: options)
    }

    /// Removes an allowed payer. Razorpay returns an empty body.
    public func removeAllowedPayer(_ payerID: String, from id: VirtualAccount.ID, options: RequestOptions = .init()) async throws {
        let payer = try RazorpayID<VirtualAccount.AllowedPayer>(payerID).pathComponent().get()
        let _: EmptyResponse = try await handler.perform(.DELETE, "/v1/virtual_accounts/\(id.pathComponent().get())/allowed_payers/\(payer)", options: options)
    }

    /// How a bank-transfer payment reached the account (payer bank, UTR).
    public func bankTransfer(for payment: PaymentID, options: RequestOptions = .init()) async throws -> BankTransfer {
        try await handler.perform(.GET, "/v1/payments/\(payment.pathComponent().get())/bank_transfer", options: options)
    }
}

extension RazorpayClient.FundAccounts {
    /// Creates a fund account for a customer.
    public func create(for customer: CustomerID, _ destination: FundAccount.Destination, options: RequestOptions = .init()) async throws -> FundAccount {
        try await handler.perform(.POST, "/v1/fund_accounts", body: FundAccountBody(customer: customer, destination: destination).validate().get(), options: options)
    }

    /// Lists a customer's fund accounts.
    public func list(for customer: CustomerID, options: RequestOptions = .init()) async throws -> [FundAccount] {
        let id = try customer.pathComponent().get()
        let page: RazorpayCollection<FundAccount> = try await handler.perform(.GET, "/v1/fund_accounts", query: ["customer_id": id], options: options)
        return page.items
    }
}
#endif
