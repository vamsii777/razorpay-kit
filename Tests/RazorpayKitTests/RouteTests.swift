import Foundation
import Testing
import RazorpayKit
@testable import RazorpayCore
@testable import RazorpayRoute

private func client(_ mock: MockTransport) -> RazorpayClient {
    RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
}

private func decode<T: Decodable>(_: T.Type, _ json: String) throws -> T {
    try RazorpayCoding.decoder.decode(T.self, from: Data(json.utf8))
}

private func roundTrip<T: Codable & Equatable>(_ v: T) throws -> T {
    try RazorpayCoding.decoder.decode(T.self, from: RazorpayCoding.encoder.encode(v))
}

/// From https://razorpay.com/docs/api/payments/route/ with fake IDs.
let transferJSON = #"{"id":"trf_TEST000001","entity":"transfer","status":"pending","source":"pay_TEST000001","recipient":"acc_TEST000001","amount":10000,"currency":"INR","amount_reversed":0,"fees":0,"tax":null,"notes":{"name":"Gaurav Kumar"},"linked_account_notes":["name"],"on_hold":true,"on_hold_until":1900000000,"settlement_status":"on_hold","recipient_settlement_id":null,"created_at":1700000000,"processed_at":null,"error":{"code":null,"description":null,"reason":null,"field":null,"step":null,"id":"trf_TEST000001","source":null,"metadata":null}}"#
let reversalJSON = #"{"id":"rvrsl_TEST000001","entity":"reversal","transfer_id":"trf_TEST000001","amount":5000,"fee":0,"tax":0,"currency":"INR","notes":[],"initiator_id":"TEST","customer_refund_id":null,"utr":null,"created_at":1700000200}"#
let accountJSON = #"{"id":"acc_TEST000001","type":"route","status":"created","email":"test@example.com","profile":{"category":"healthcare","subcategory":"clinic","addresses":{"registered":{"street1":"507, Koramangala 1st block","street2":"MG Road","city":"Bengaluru","state":"KARNATAKA","postal_code":560034,"country":"IN"}}},"notes":[],"created_at":1700000000,"phone":9000090000,"reference_id":"124124","business_type":"partnership","legal_business_name":"Acme Corp","customer_facing_business_name":"Example","legal_info":{"pan":"AAACL1234C","gst":"18AABCU9603R1ZM"},"contact_name":"Test User","live":false,"hold_funds":false}"#
let stakeholderJSON = #"{"entity":"stakeholder","relationship":{"director":true,"executive":false},"phone":{"primary":"9000090000","secondary":null},"notes":{"random_key_by_partner":"random_value"},"kyc":{"pan":"AVOPB1111K"},"id":"sth_TEST000001","name":"Test User","email":"test@example.com","percentage_ownership":10,"addresses":{"residential":{"street":"506, Koramangala 1st block","city":"Bengaluru","state":"Karnataka","postal_code":"560034","country":"IN"}}}"#

@Suite("Route models")
struct RouteModelTests {
    @Test func transfer() throws {
        let t = try decode(Transfer.self, transferJSON)
        #expect(t.status == .pending && t.recipient == "acc_TEST000001" && t.amount == .inr(paise: 10_000))
        #expect(t.onHold && t.settlementStatus == .onHold && t.failure == nil, "all-null error means no failure")
        #expect(t.linkedAccountNotes == ["name"] && t.tax == nil)
        #expect(try roundTrip(t) == t)
        let failed = try decode(Transfer.self, transferJSON.replacingOccurrences(of: #""code":null,"description":null"#, with: #""code":"BAD_REQUEST_ERROR","description":"Insufficient balance""#).replacingOccurrences(of: #""status":"pending""#, with: #""status":"stuck""#))
        #expect(failed.failure?.code == .badRequestError && failed.status.rawValue == "stuck")
    }

    @Test func reversalAccountStakeholder() throws {
        let r = try decode(Reversal.self, reversalJSON)
        #expect(r.transferID == "trf_TEST000001" && r.amount == .inr(paise: 5_000) && r.notes.isEmpty)
        #expect(try roundTrip(r) == r)
        let a = try decode(LinkedAccount.self, accountJSON)
        #expect(a.phone == "9000090000" && a.profile?.addresses["registered"]?.postalCode == "560034" && a.status == .created)
        #expect(a.legalInfo?.gst == "18AABCU9603R1ZM" && !a.live)
        #expect(try roundTrip(a) == a)
        let s = try decode(Stakeholder.self, stakeholderJSON)
        #expect(s.relationship?.director == true && s.percentageOwnership == 10 && s.kyc?.pan == "AVOPB1111K")
        #expect(s.addresses["residential"]?.city == "Bengaluru" && s.phone?.secondary == nil)
        #expect(try roundTrip(s) == s)
    }
}

@Suite("Route API")
struct RouteAPITests {
    @Test func transferFromPayment() async throws {
        let mock = MockTransport(json: #"{"entity":"collection","count":1,"items":[\#(transferJSON)]}"#)
        let out = try await client(mock).transfers.create(from: "pay_TEST000001", [
            .init(account: "acc_TEST000001", amount: .inr(paise: 10_000), notes: ["name": "x"], linkedAccountNotes: ["name"], onHoldUntil: Date(timeIntervalSince1970: 1_900_000_000)),
        ])
        #expect(out.count == 1)
        let request = await mock.lastRequest
        #expect(request?.path == "/v1/payments/pay_TEST000001/transfers")
        let body = try #require(try MockTransport.json(request?.body)?["transfers"] as? [[String: Any]])
        #expect(body[0]["account"] as? String == "acc_TEST000001" && body[0]["on_hold"] as? Bool == true && body[0]["currency"] as? String == "INR")
    }

    @Test func validationSendsNothing() async {
        let mock = MockTransport()
        let rzp = client(mock)
        await #expect(throws: RazorpayError.self) { try await rzp.transfers.create(from: "pay_TEST000001", []) }
        await #expect(throws: RazorpayError.self) { try await rzp.transfers.create(from: "pay_TEST000001", [.init(account: "acc_1", amount: .inr(paise: 0))]) }
        await #expect(throws: RazorpayError.self) { try await rzp.transfers.create(.init(account: "", amount: .inr(paise: 10))) }
        await #expect(throws: RazorpayError.self) { try await rzp.transfers.reverse("trf_1", amount: .inr(paise: -1)) }
        await #expect(throws: RazorpayError.self) { try await rzp.linkedAccounts.addStakeholder(to: "acc_1", .init(percentageOwnership: 101)) }
        #expect(await mock.requests.isEmpty)
    }

    @Test func transferCalls() async throws {
        let mock = MockTransport { request in
            let json: String
            if request.path.hasSuffix("/reversals") {
                json = request.method == .POST ? reversalJSON : #"{"entity":"collection","count":1,"items":[\#(reversalJSON)]}"#
            } else if request.method == .GET && (request.path == "/v1/transfers" || request.path.hasSuffix("/transfers")) {
                json = #"{"entity":"collection","count":1,"items":[\#(transferJSON)]}"#
            } else { json = transferJSON }
            return RazorpayHTTPResponse(status: .ok, body: Data(json.utf8))
        }
        let rzp = client(mock)
        _ = try await rzp.transfers.create(.init(account: "acc_TEST000001", amount: .inr(paise: 100)))
        _ = try await rzp.transfers.fetch("trf_TEST000001")
        var n = 0; for try await _ in rzp.transfers.list(.init(limit: 1)) { n += 1 }
        #expect(n == 1)
        #expect(try await rzp.transfers.list(of: "pay_TEST000001").count == 1)
        _ = try await rzp.transfers.hold("trf_TEST000001", false, until: Date())
        #expect(try MockTransport.json(await mock.lastRequest?.body) as NSDictionary? == ["on_hold": false], "release drops until")
        let r = try await rzp.transfers.reverse("trf_TEST000001", amount: .inr(paise: 5_000))
        #expect(r.amount == .inr(paise: 5_000))
        #expect(try MockTransport.json(await mock.lastRequest?.body) as NSDictionary? == ["amount": 5_000])
        #expect(try await rzp.transfers.reversals(of: "trf_TEST000001").count == 1)
        let calls = await mock.requests.map { "\($0.method) \($0.path)" }
        #expect(calls == ["POST /v1/transfers", "GET /v1/transfers/trf_TEST000001", "GET /v1/transfers", "GET /v1/payments/pay_TEST000001/transfers",
                          "PATCH /v1/transfers/trf_TEST000001", "POST /v1/transfers/trf_TEST000001/reversals", "GET /v1/transfers/trf_TEST000001/reversals"])
    }

    @Test func accountsAndStakeholders() async throws {
        let mock = MockTransport { request in
            let json = request.path.contains("/stakeholders")
                ? (request.method == .GET && request.path.hasSuffix("stakeholders") ? #"{"entity":"collection","count":1,"items":[\#(stakeholderJSON)]}"# : stakeholderJSON)
                : accountJSON
            return RazorpayHTTPResponse(status: .ok, body: Data(json.utf8))
        }
        let rzp = client(mock)
        _ = try await rzp.linkedAccounts.create(.init(email: "test@example.com", phone: "9000090000", legalBusinessName: "Acme Corp",
                                                     businessType: "partnership", contactName: "Test User"))
        #expect(try MockTransport.json(await mock.lastRequest?.body)?["type"] as? String == "route")
        _ = try await rzp.linkedAccounts.fetch("acc_TEST000001")
        _ = try await rzp.linkedAccounts.update("acc_TEST000001", .init(contactName: "New"))
        _ = try await rzp.linkedAccounts.delete("acc_TEST000001")
        _ = try await rzp.linkedAccounts.addStakeholder(to: "acc_TEST000001", .init(name: "Test User", percentageOwnership: 10))
        _ = try await rzp.linkedAccounts.stakeholder("sth_TEST000001", of: "acc_TEST000001")
        #expect(try await rzp.linkedAccounts.stakeholders(of: "acc_TEST000001").count == 1)
        _ = try await rzp.linkedAccounts.updateStakeholder("sth_TEST000001", of: "acc_TEST000001", .init(email: "x@example.com"))
        let calls = await mock.requests.map { "\($0.method) \($0.path)" }
        #expect(calls == ["POST /v2/accounts", "GET /v2/accounts/acc_TEST000001", "PATCH /v2/accounts/acc_TEST000001", "DELETE /v2/accounts/acc_TEST000001",
                          "POST /v2/accounts/acc_TEST000001/stakeholders", "GET /v2/accounts/acc_TEST000001/stakeholders/sth_TEST000001",
                          "GET /v2/accounts/acc_TEST000001/stakeholders", "PATCH /v2/accounts/acc_TEST000001/stakeholders/sth_TEST000001"])
    }
}

@Suite("Null error objects")
struct NullErrorObjectTests {
    @Test func allNullErrorIsNotAnAPIError() {
        #expect(RazorpayError.APIError(errorObject: ["error": ["code": NSNull(), "description": NSNull()]], statusCode: 200) == nil)
        #expect(RazorpayError.APIError(errorObject: ["error": ["code": NSNull()]], statusCode: 400) != nil)
        #expect(RazorpayError.APIError(errorObject: ["error": ["code": "BAD_REQUEST_ERROR"]], statusCode: 200) != nil)
    }
}
