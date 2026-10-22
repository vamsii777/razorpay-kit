import Foundation
import Testing
import RazorpayKit
@testable import RazorpayCore
@testable import RazorpaySmartCollect

private func client(_ mock: MockTransport) -> RazorpayClient {
    RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
}

private func decode<T: Decodable>(_: T.Type, _ json: String) throws -> T {
    try RazorpayCoding.decoder.decode(T.self, from: Data(json.utf8))
}

/// From https://razorpay.com/docs/api/payments/smart-collect/ with fake IDs.
let vaJSON = #"{"id":"va_TEST000001","name":"Acme Corp","entity":"virtual_account","status":"active","description":"Virtual Account for Raftar Soft","amount_expected":null,"notes":{"project_name":"Banking Software"},"amount_paid":0,"customer_id":"cust_TEST000001","receivers":[{"id":"ba_TEST000001","entity":"bank_account","ifsc":"RATN0VAAPIS","bank_name":"RBL Bank","name":"Acme Corp","notes":[],"account_number":"2223330099089860"},{"id":"vpa_TEST000001","entity":"vpa","username":"rpy.payto00000test","handle":"icici","address":"rpy.payto00000test@icici"},{"id":"hol_TEST","entity":"hologram","x":1}],"allowed_payers":[{"type":"bank_account","id":"ba_TEST000002","bank_account":{"ifsc":"UTIB0000013","account_number":914010012345679}}],"close_by":1900000000,"closed_at":null,"created_at":1700000000}"#
let faJSON = #"{"id":"fa_TEST000001","entity":"fund_account","customer_id":"cust_TEST000001","account_type":"bank_account","bank_account":{"ifsc":"HDFC0000053","bank_name":"HDFC Bank","name":"Test User","account_number":"765432123456789","notes":[]},"active":true,"batch_id":null,"created_at":1700000000}"#
let btJSON = #"{"id":"bt_TEST000001","entity":"bank_transfer","payment_id":"pay_TEST000001","mode":"NEFT","bank_reference":"157414364471","amount":239000,"payer_bank_account":{"id":"ba_TEST000003","entity":"bank_account","ifsc":"RATN0VAAPIS","bank_name":"RBL Bank","name":"Test User","account_number":"2223330027558515"},"virtual_account_id":"va_TEST000001","virtual_account":{}}"#

@Suite("Smart Collect models")
struct SmartCollectModelTests {
    @Test func virtualAccount() throws {
        let va = try decode(VirtualAccount.self, vaJSON)
        #expect(va.status == .active && va.amountExpected == nil && va.amountPaid == .inr(paise: 0))
        #expect(va.bankAccount?.ifsc == "RATN0VAAPIS" && va.vpa?.fullAddress == "rpy.payto00000test@icici")
        guard case .other(let entity, _) = va.receivers[2] else { Issue.record("unknown receiver should be .other"); return }
        #expect(entity == "hologram")
        #expect(va.allowedPayers.first?.bankAccount?.accountNumber == "914010012345679", "numeric account numbers become strings")
        #expect(try decode(VirtualAccount.self, String(decoding: RazorpayCoding.encoder.encode(va), as: UTF8.self)) == va)
    }

    @Test func fundAccountAndBankTransfer() throws {
        let fa = try decode(FundAccount.self, faJSON)
        #expect(fa.accountType == .bankAccount && fa.bankAccount?.bankName == "HDFC Bank" && fa.active)
        #expect(try decode(FundAccount.self, String(decoding: RazorpayCoding.encoder.encode(fa), as: UTF8.self)) == fa)
        let bt = try decode(BankTransfer.self, btJSON)
        #expect(bt.mode == "NEFT" && bt.amount == .inr(paise: 239_000) && bt.virtualAccountID == "va_TEST000001")
        #expect(VPAAddress(username: "a", handle: "b").fullAddress == "a@b")
    }
}

@Suite("Smart Collect API")
struct SmartCollectAPITests {
    @Test func createEncodesReceivers() async throws {
        let mock = MockTransport(json: vaJSON)
        _ = try await client(mock).virtualAccounts.create(.init(receivers: [.vpa, .bankAccount], vpaDescriptor: "acme",
                                                                customerID: "cust_TEST000001", amountExpected: .inr(rupees: 10)))
        let body = try #require(try MockTransport.json(await mock.lastRequest?.body))
        let receivers = try #require(body["receivers"] as? [String: Any])
        #expect(receivers["types"] as? [String] == ["bank_account", "vpa"] && (receivers["vpa"] as? [String: String])?["descriptor"] == "acme")
        #expect(body["amount_expected"] as? Int == 1_000 && body["allowed_payers"] == nil)
    }

    @Test func validationSendsNothing() async {
        let mock = MockTransport()
        let rzp = client(mock)
        await #expect(throws: RazorpayError.self) { try await rzp.virtualAccounts.create(.init(receivers: [])) }
        await #expect(throws: RazorpayError.self) { try await rzp.virtualAccounts.create(.init(receivers: [.vpa], amountExpected: Money(amount: 1, currency: .usd))) }
        await #expect(throws: RazorpayError.self) { try await rzp.virtualAccounts.addReceivers([], to: "va_1") }
        await #expect(throws: RazorpayError.self) { try await rzp.virtualAccounts.removeAllowedPayer("", from: "va_1") }
        await #expect(throws: RazorpayError.self) { try await rzp.fundAccounts.create(for: "cust_1", .vpa("not-a-vpa")) }
        await #expect(throws: RazorpayError.self) { try await rzp.fundAccounts.create(for: "cust_1", .bankAccount(name: "A", ifsc: "SHORT", accountNumber: "1")) }
        await #expect(throws: RazorpayError.self) { try await rzp.fundAccounts.list(for: "") }
        #expect(await mock.requests.isEmpty)
    }

    @Test func calls() async throws {
        let mock = MockTransport { request in
            let json: String
            if request.method == .DELETE { json = "" }
            else if request.path.hasSuffix("/bank_transfer") { json = btJSON }
            else if request.path == "/v1/fund_accounts" { json = request.method == .GET ? #"{"entity":"collection","count":1,"items":[\#(faJSON)]}"# : faJSON }
            else if request.path.hasSuffix("/payments") { json = #"{"entity":"collection","count":1,"items":[\#(Fixtures.payment)]}"# }
            else if request.path == "/v1/virtual_accounts" && request.method == .GET { json = #"{"entity":"collection","count":1,"items":[\#(vaJSON)]}"# }
            else { json = vaJSON }
            return RazorpayHTTPResponse(status: request.method == .DELETE ? .noContent : .ok, body: Data(json.utf8))
        }
        let rzp = client(mock)
        _ = try await rzp.virtualAccounts.fetch("va_TEST000001")
        var n = 0; for try await _ in rzp.virtualAccounts.list(.init(limit: 1)) { n += 1 }
        for try await _ in rzp.virtualAccounts.payments(of: "va_TEST000001", .init(limit: 1)) { n += 1 }
        #expect(n == 2)
        _ = try await rzp.virtualAccounts.close("va_TEST000001")
        _ = try await rzp.virtualAccounts.addReceivers([.vpa], to: "va_TEST000001")
        _ = try await rzp.virtualAccounts.addAllowedPayer(BankAccount(ifsc: "UTIB0000013", accountNumber: "914010012345679"), to: "va_TEST000001")
        #expect(try MockTransport.json(await mock.lastRequest?.body)?["type"] as? String == "bank_account")
        try await rzp.virtualAccounts.removeAllowedPayer("ba_TEST000002", from: "va_TEST000001")
        #expect(try await rzp.virtualAccounts.bankTransfer(for: "pay_TEST000001").bankReference == "157414364471")
        _ = try await rzp.fundAccounts.create(for: "cust_TEST000001", .bankAccount(name: "Test User", ifsc: "hdfc0000053", accountNumber: "765432123456789"))
        let fa = try #require(try MockTransport.json(await mock.lastRequest?.body))
        #expect((fa["bank_account"] as? [String: String])?["ifsc"] == "HDFC0000053" && fa["account_type"] as? String == "bank_account")
        #expect(try await rzp.fundAccounts.list(for: "cust_TEST000001").count == 1)
        #expect(await mock.lastRequest?.query["customer_id"] == "cust_TEST000001")
        let calls = await mock.requests.map { "\($0.method) \($0.path)" }
        #expect(calls.contains("DELETE /v1/virtual_accounts/va_TEST000001/allowed_payers/ba_TEST000002"))
        #expect(calls.contains("POST /v1/virtual_accounts/va_TEST000001/receivers") && calls.contains("POST /v1/virtual_accounts/va_TEST000001/close"))
    }
}
