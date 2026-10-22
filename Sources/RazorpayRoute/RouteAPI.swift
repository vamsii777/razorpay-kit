import Foundation
import RazorpayCore

#if compiler(>=6.0)
extension RazorpayClient.Transfers {
    /// Splits a captured payment into transfers to linked accounts.
    public func create(from payment: PaymentID, _ transfers: [Transfer.Create], options: RequestOptions = .init()) async throws(RazorpayError) -> [Transfer] {
        guard !transfers.isEmpty else { throw RazorpayError.invalidRequest("no transfers") }
        let body = try TransfersBody(transfers: Transfer.Create.validateAll(transfers).get())
        let page: RazorpayCollection<Transfer> = try await handler.perform(.POST, "/v1/payments/\(payment.pathComponent().get())/transfers", body: body, options: options)
        return page.items
    }

    /// Transfers from your account balance to a linked account (direct transfer).
    public func create(_ transfer: Transfer.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> Transfer {
        try await handler.perform(.POST, "/v1/transfers", body: transfer.validate().get(), options: options)
    }

    /// Fetches a transfer.
    public func fetch(_ id: Transfer.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Transfer {
        try await handler.perform(.GET, "/v1/transfers/\(id.pathComponent().get())", options: options)
    }

    /// Lists transfers, fetching pages lazily. Filter with `recipient_settlement_id` in `ListOptions.filters`.
    public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Transfer> {
        RazorpayList(handler: handler, path: "/v1/transfers", options: list, request: options)
    }

    /// Lists the transfers made from a payment.
    public func list(of payment: PaymentID, options: RequestOptions = .init()) async throws(RazorpayError) -> [Transfer] {
        let page: RazorpayCollection<Transfer> = try await handler.perform(.GET, "/v1/payments/\(payment.pathComponent().get())/transfers", options: options)
        return page.items
    }

    /// Holds a transfer's settlement, optionally until a date, or releases it (`onHold: false`).
    public func hold(_ id: Transfer.ID, _ onHold: Bool = true, until: Date? = nil, options: RequestOptions = .init()) async throws(RazorpayError) -> Transfer {
        try await handler.perform(.PATCH, "/v1/transfers/\(id.pathComponent().get())", body: HoldBody(onHold: onHold, onHoldUntil: onHold ? until : nil), options: options)
    }

    /// Reverses a transfer, fully (`amount: nil`) or partly.
    public func reverse(_ id: Transfer.ID, amount: Money? = nil, notes: Notes = [:], options: RequestOptions = .init()) async throws(RazorpayError) -> Reversal {
        if let amount, amount.amount <= 0 { throw RazorpayError.invalidRequest("reversal amount must be positive") }
        return try await handler.perform(.POST, "/v1/transfers/\(id.pathComponent().get())/reversals",
                                         body: ReversalBody(amount: amount?.amount, notes: notes.isEmpty ? nil : notes), options: options)
    }

    /// Lists a transfer's reversals.
    public func reversals(of id: Transfer.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> [Reversal] {
        let page: RazorpayCollection<Reversal> = try await handler.perform(.GET, "/v1/transfers/\(id.pathComponent().get())/reversals", options: options)
        return page.items
    }
}

extension RazorpayClient.LinkedAccounts {
    /// Creates a Route linked account.
    public func create(_ account: LinkedAccount.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> LinkedAccount {
        try await handler.perform(.POST, "/v2/accounts", body: account, options: options)
    }

    /// Fetches a linked account.
    public func fetch(_ id: LinkedAccount.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> LinkedAccount {
        try await handler.perform(.GET, "/v2/accounts/\(id.pathComponent().get())", options: options)
    }

    /// Updates a linked account.
    public func update(_ id: LinkedAccount.ID, _ changes: LinkedAccount.Update, options: RequestOptions = .init()) async throws(RazorpayError) -> LinkedAccount {
        try await handler.perform(.PATCH, "/v2/accounts/\(id.pathComponent().get())", body: changes, options: options)
    }

    /// Deletes (suspends) a linked account.
    public func delete(_ id: LinkedAccount.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> LinkedAccount {
        try await handler.perform(.DELETE, "/v2/accounts/\(id.pathComponent().get())", options: options)
    }

    /// Adds a stakeholder to a linked account.
    public func addStakeholder(to account: LinkedAccount.ID, _ details: Stakeholder.Details, options: RequestOptions = .init()) async throws(RazorpayError) -> Stakeholder {
        try await handler.perform(.POST, "/v2/accounts/\(account.pathComponent().get())/stakeholders", body: details.validate().get(), options: options)
    }

    /// Fetches one of a linked account's stakeholders.
    public func stakeholder(_ id: Stakeholder.ID, of account: LinkedAccount.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Stakeholder {
        try await handler.perform(.GET, "/v2/accounts/\(account.pathComponent().get())/stakeholders/\(id.pathComponent().get())", options: options)
    }

    /// Lists a linked account's stakeholders.
    public func stakeholders(of account: LinkedAccount.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> [Stakeholder] {
        let page: RazorpayCollection<Stakeholder> = try await handler.perform(.GET, "/v2/accounts/\(account.pathComponent().get())/stakeholders", options: options)
        return page.items
    }

    /// Updates a stakeholder.
    public func updateStakeholder(_ id: Stakeholder.ID, of account: LinkedAccount.ID, _ details: Stakeholder.Details, options: RequestOptions = .init()) async throws(RazorpayError) -> Stakeholder {
        try await handler.perform(.PATCH, "/v2/accounts/\(account.pathComponent().get())/stakeholders/\(id.pathComponent().get())", body: details.validate().get(), options: options)
    }
}
#else
extension RazorpayClient.Transfers {
    /// Splits a captured payment into transfers to linked accounts.
    public func create(from payment: PaymentID, _ transfers: [Transfer.Create], options: RequestOptions = .init()) async throws -> [Transfer] {
        guard !transfers.isEmpty else { throw RazorpayError.invalidRequest("no transfers") }
        let body = try TransfersBody(transfers: Transfer.Create.validateAll(transfers).get())
        let page: RazorpayCollection<Transfer> = try await handler.perform(.POST, "/v1/payments/\(payment.pathComponent().get())/transfers", body: body, options: options)
        return page.items
    }

    /// Transfers from your account balance to a linked account (direct transfer).
    public func create(_ transfer: Transfer.Create, options: RequestOptions = .init()) async throws -> Transfer {
        try await handler.perform(.POST, "/v1/transfers", body: transfer.validate().get(), options: options)
    }

    /// Fetches a transfer.
    public func fetch(_ id: Transfer.ID, options: RequestOptions = .init()) async throws -> Transfer {
        try await handler.perform(.GET, "/v1/transfers/\(id.pathComponent().get())", options: options)
    }

    /// Lists transfers, fetching pages lazily. Filter with `recipient_settlement_id` in `ListOptions.filters`.
    public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Transfer> {
        RazorpayList(handler: handler, path: "/v1/transfers", options: list, request: options)
    }

    /// Lists the transfers made from a payment.
    public func list(of payment: PaymentID, options: RequestOptions = .init()) async throws -> [Transfer] {
        let page: RazorpayCollection<Transfer> = try await handler.perform(.GET, "/v1/payments/\(payment.pathComponent().get())/transfers", options: options)
        return page.items
    }

    /// Holds a transfer's settlement, optionally until a date, or releases it (`onHold: false`).
    public func hold(_ id: Transfer.ID, _ onHold: Bool = true, until: Date? = nil, options: RequestOptions = .init()) async throws -> Transfer {
        try await handler.perform(.PATCH, "/v1/transfers/\(id.pathComponent().get())", body: HoldBody(onHold: onHold, onHoldUntil: onHold ? until : nil), options: options)
    }

    /// Reverses a transfer, fully (`amount: nil`) or partly.
    public func reverse(_ id: Transfer.ID, amount: Money? = nil, notes: Notes = [:], options: RequestOptions = .init()) async throws -> Reversal {
        if let amount, amount.amount <= 0 { throw RazorpayError.invalidRequest("reversal amount must be positive") }
        return try await handler.perform(.POST, "/v1/transfers/\(id.pathComponent().get())/reversals",
                                         body: ReversalBody(amount: amount?.amount, notes: notes.isEmpty ? nil : notes), options: options)
    }

    /// Lists a transfer's reversals.
    public func reversals(of id: Transfer.ID, options: RequestOptions = .init()) async throws -> [Reversal] {
        let page: RazorpayCollection<Reversal> = try await handler.perform(.GET, "/v1/transfers/\(id.pathComponent().get())/reversals", options: options)
        return page.items
    }
}

extension RazorpayClient.LinkedAccounts {
    /// Creates a Route linked account.
    public func create(_ account: LinkedAccount.Create, options: RequestOptions = .init()) async throws -> LinkedAccount {
        try await handler.perform(.POST, "/v2/accounts", body: account, options: options)
    }

    /// Fetches a linked account.
    public func fetch(_ id: LinkedAccount.ID, options: RequestOptions = .init()) async throws -> LinkedAccount {
        try await handler.perform(.GET, "/v2/accounts/\(id.pathComponent().get())", options: options)
    }

    /// Updates a linked account.
    public func update(_ id: LinkedAccount.ID, _ changes: LinkedAccount.Update, options: RequestOptions = .init()) async throws -> LinkedAccount {
        try await handler.perform(.PATCH, "/v2/accounts/\(id.pathComponent().get())", body: changes, options: options)
    }

    /// Deletes (suspends) a linked account.
    public func delete(_ id: LinkedAccount.ID, options: RequestOptions = .init()) async throws -> LinkedAccount {
        try await handler.perform(.DELETE, "/v2/accounts/\(id.pathComponent().get())", options: options)
    }

    /// Adds a stakeholder to a linked account.
    public func addStakeholder(to account: LinkedAccount.ID, _ details: Stakeholder.Details, options: RequestOptions = .init()) async throws -> Stakeholder {
        try await handler.perform(.POST, "/v2/accounts/\(account.pathComponent().get())/stakeholders", body: details.validate().get(), options: options)
    }

    /// Fetches one of a linked account's stakeholders.
    public func stakeholder(_ id: Stakeholder.ID, of account: LinkedAccount.ID, options: RequestOptions = .init()) async throws -> Stakeholder {
        try await handler.perform(.GET, "/v2/accounts/\(account.pathComponent().get())/stakeholders/\(id.pathComponent().get())", options: options)
    }

    /// Lists a linked account's stakeholders.
    public func stakeholders(of account: LinkedAccount.ID, options: RequestOptions = .init()) async throws -> [Stakeholder] {
        let page: RazorpayCollection<Stakeholder> = try await handler.perform(.GET, "/v2/accounts/\(account.pathComponent().get())/stakeholders", options: options)
        return page.items
    }

    /// Updates a stakeholder.
    public func updateStakeholder(_ id: Stakeholder.ID, of account: LinkedAccount.ID, _ details: Stakeholder.Details, options: RequestOptions = .init()) async throws -> Stakeholder {
        try await handler.perform(.PATCH, "/v2/accounts/\(account.pathComponent().get())/stakeholders/\(id.pathComponent().get())", body: details.validate().get(), options: options)
    }
}
#endif
