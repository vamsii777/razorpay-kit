import Foundation
import NIOHTTP1
import RazorpayCore

extension RazorpayClient {
    /// Settlements, instant settlements and the reconciliation report.
    /// See https://razorpay.com/docs/api/settlements/.
    public var settlements: Settlements { Settlements(handler: handler) }

    /// IIN (card BIN) lookups. See https://razorpay.com/docs/api/payments/cards/iin-api/.
    public var iins: IINs { IINs(handler: handler) }

    /// Settlements, instant settlements and the reconciliation report.
    /// See https://razorpay.com/docs/api/settlements/.
    public struct Settlements: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }

    /// IIN (card BIN) lookups. See https://razorpay.com/docs/api/payments/cards/iin-api/.
    public struct IINs: Sendable {
        package let handler: RazorpayAPIHandler
        package init(handler: RazorpayAPIHandler) { self.handler = handler }
    }
}

/// The period for a settlement reconciliation report.
public struct SettlementReconPeriod: Sendable, Hashable {
    public var year: Int
    public var month: Int
    /// Leave `nil` for the whole month.
    public var day: Int?

    public init(year: Int, month: Int, day: Int? = nil) {
        self.year = year
        self.month = month
        self.day = day
    }

    var query: [String: String] {
        var q = ["year": String(year), "month": String(month)]
        if let day { q["day"] = String(day) }
        return q
    }

    var isValid: Bool { (1...12).contains(month) && year > 0 && (day.map { (1...31).contains($0) } ?? true) }
}

private extension ListOptions {
    func adding(_ extra: [String: String]) -> ListOptions {
        var copy = self
        copy.filters.merge(extra) { _, new in new }
        return copy
    }
}

private func validated(_ period: SettlementReconPeriod) -> Result<SettlementReconPeriod, RazorpayError> {
    period.isValid ? .success(period) : .failure(.invalidRequest("settlement recon period \(period.year)-\(period.month)-\(period.day.map(String.init) ?? "*") is invalid"))
}

private func iinPath(_ iin: String) -> Result<String, RazorpayError> {
    let digits = iin.trimmingCharacters(in: .whitespaces)
    guard (6...9).contains(digits.count), digits.allSatisfy(\.isASCII), digits.allSatisfy(\.isNumber) else {
        return .failure(.invalidRequest("IIN must be 6 to 9 digits"))
    }
    return .success("/v1/iins/\(digits)")
}
#if compiler(>=6.0)
extension RazorpayClient.Settlements {
        /// Fetches a settlement.
        public func fetch(_ id: Settlement.ID, options: RequestOptions = .init()) async throws(RazorpayError) -> Settlement {
            try await handler.perform(.GET, "/v1/settlements/\(id.pathComponent().get())", options: options)
        }

        /// Lists settlements, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Settlement> {
            RazorpayList(handler: handler, path: "/v1/settlements", options: list, request: options)
        }

        /// Lists every settled transaction for a day or month, fetching pages lazily.
        public func recon(_ period: SettlementReconPeriod, _ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<SettlementReconEntry> {
            RazorpayList(handler: handler, path: validated(period).map { _ in "/v1/settlements/recon/combined" },
                         options: list.adding(period.query), request: options)
        }

        /// Requests an instant settlement of an amount or the full balance.
        public func createInstant(_ settlement: InstantSettlement.Create, options: RequestOptions = .init()) async throws(RazorpayError) -> InstantSettlement {
            try await handler.perform(.POST, "/v1/settlements/ondemand", body: settlement, options: options)
        }

        /// Fetches an instant settlement. Pass `expandPayouts` to include its payouts.
        public func fetchInstant(_ id: InstantSettlement.ID, expandPayouts: Bool = false, options: RequestOptions = .init()) async throws(RazorpayError) -> InstantSettlement {
            try await handler.perform(.GET, "/v1/settlements/ondemand/\(id.pathComponent().get())",
                                      query: expandPayouts ? ["expand[]": "ondemand_payouts"] : [:], options: options)
        }

        /// Lists instant settlements, fetching pages lazily.
        public func listInstant(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<InstantSettlement> {
            RazorpayList(handler: handler, path: "/v1/settlements/ondemand", options: list, request: options)
        }
}

extension RazorpayClient.IINs {
        /// Looks up a card or token IIN (6 to 9 digits).
        public func fetch(_ iin: String, options: RequestOptions = .init()) async throws(RazorpayError) -> IIN {
            try await handler.perform(.GET, iinPath(iin).get(), options: options)
        }

        /// Lists IINs that support a flow, such as native OTP.
        public func list(flow: IIN.Flow, options: RequestOptions = .init()) async throws(RazorpayError) -> [String] {
            try await handler.perform(.GET, "/v1/iins/list", query: ["flow": flow.rawValue], options: options, as: IINList.self).iins ?? []
        }

        /// Lists IINs of a card sub-type, such as business cards.
        public func list(subType: IIN.SubType, options: RequestOptions = .init()) async throws(RazorpayError) -> [String] {
            try await handler.perform(.GET, "/v1/iins/list", query: ["sub_type": subType.rawValue], options: options, as: IINList.self).iins ?? []
        }
}
#else
extension RazorpayClient.Settlements {
        /// Fetches a settlement.
        public func fetch(_ id: Settlement.ID, options: RequestOptions = .init()) async throws -> Settlement {
            try await handler.perform(.GET, "/v1/settlements/\(id.pathComponent().get())", options: options)
        }

        /// Lists settlements, fetching pages lazily.
        public func list(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<Settlement> {
            RazorpayList(handler: handler, path: "/v1/settlements", options: list, request: options)
        }

        /// Lists every settled transaction for a day or month, fetching pages lazily.
        public func recon(_ period: SettlementReconPeriod, _ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<SettlementReconEntry> {
            RazorpayList(handler: handler, path: validated(period).map { _ in "/v1/settlements/recon/combined" },
                         options: list.adding(period.query), request: options)
        }

        /// Requests an instant settlement of an amount or the full balance.
        public func createInstant(_ settlement: InstantSettlement.Create, options: RequestOptions = .init()) async throws -> InstantSettlement {
            try await handler.perform(.POST, "/v1/settlements/ondemand", body: settlement, options: options)
        }

        /// Fetches an instant settlement. Pass `expandPayouts` to include its payouts.
        public func fetchInstant(_ id: InstantSettlement.ID, expandPayouts: Bool = false, options: RequestOptions = .init()) async throws -> InstantSettlement {
            try await handler.perform(.GET, "/v1/settlements/ondemand/\(id.pathComponent().get())",
                                      query: expandPayouts ? ["expand[]": "ondemand_payouts"] : [:], options: options)
        }

        /// Lists instant settlements, fetching pages lazily.
        public func listInstant(_ list: ListOptions = .init(), options: RequestOptions = .init()) -> RazorpayList<InstantSettlement> {
            RazorpayList(handler: handler, path: "/v1/settlements/ondemand", options: list, request: options)
        }
}

extension RazorpayClient.IINs {
        /// Looks up a card or token IIN (6 to 9 digits).
        public func fetch(_ iin: String, options: RequestOptions = .init()) async throws -> IIN {
            try await handler.perform(.GET, iinPath(iin).get(), options: options)
        }

        /// Lists IINs that support a flow, such as native OTP.
        public func list(flow: IIN.Flow, options: RequestOptions = .init()) async throws -> [String] {
            try await handler.perform(.GET, "/v1/iins/list", query: ["flow": flow.rawValue], options: options, as: IINList.self).iins ?? []
        }

        /// Lists IINs of a card sub-type, such as business cards.
        public func list(subType: IIN.SubType, options: RequestOptions = .init()) async throws -> [String] {
            try await handler.perform(.GET, "/v1/iins/list", query: ["sub_type": subType.rawValue], options: options, as: IINList.self).iins ?? []
        }
}
#endif
