import Foundation
import Testing
import RazorpayKit
@testable import RazorpayCore
@testable import RazorpayCards

private func client(_ mock: MockTransport) -> RazorpayClient {
    RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
}

/// From https://razorpay.com/docs/api/payments/tokens/ with fake IDs.
private let cardToken = #"{"id":"token_TEST000001","entity":"token","token":"FAKETOKENVALUE","bank":null,"wallet":null,"method":"card","card":{"entity":"card","name":"Test User","last4":"1111","network":"Visa","type":"credit","issuer":"HDFC","international":false,"emi":true,"sub_type":"consumer","expiry_month":"12","expiry_year":2030,"flows":{"otp":true,"recurring":true}},"recurring":true,"recurring_details":{"status":"confirmed","failure_reason":null},"auth_type":null,"mrn":null,"used_at":1700000100,"created_at":1700000000,"expired_at":1900000000,"dcc_enabled":false,"compliant_with_tokenisation_guidelines":true,"status":"active","notes":[]}"#
private let upiToken = #"{"id":"token_TEST000002","entity":"token","method":"upi","vpa":{"username":"test","handle":"upi","name":"Test User"},"recurring":1,"recurring_details":{"status":"hibernating"},"max_amount":500000,"created_at":1700000000,"notes":{"plan":"gold"}}"#

@Suite("Tokens")
struct TokenTests {
    @Test func decodesCardToken() throws {
        let t = try RazorpayCoding.decoder.decode(Token.self, from: Data(cardToken.utf8))
        #expect(t.id == "token_TEST000001" && t.method == .card && t.recurring && t.status == .active)
        #expect(t.card?.network == .visa && t.card?.type == .credit && t.card?.expiryMonth == 12 && t.card?.expiryYear == 2030)
        #expect(t.card?.flows["recurring"] == true && t.recurringDetails?.status == .confirmed)
        #expect(t.notes.isEmpty && t.compliantWithTokenisationGuidelines == true)
        #expect(try RazorpayCoding.decoder.decode(Token.self, from: RazorpayCoding.encoder.encode(t)) == t)
    }

    @Test func decodesUPITokenWithUnknownStatus() throws {
        let t = try RazorpayCoding.decoder.decode(Token.self, from: Data(upiToken.utf8))
        #expect(t.vpa?.handle == "upi" && t.recurring && t.maxAmount == 500_000 && t.notes == ["plan": "gold"])
        #expect(t.recurringDetails?.status?.rawValue == "hibernating" && t.card == nil && t.status == nil)
    }

    @Test func listFetchDelete() async throws {
        let mock = MockTransport { request in
            let json: String
            switch request.method {
            case .DELETE: json = #"{"deleted":true}"#
            default: json = request.path.hasSuffix("/tokens") ? #"{"entity":"collection","count":2,"items":[\#(cardToken),\#(upiToken)]}"# : cardToken
            }
            return RazorpayHTTPResponse(status: .ok, body: Data(json.utf8))
        }
        let rzp = client(mock)
        #expect(try await rzp.tokens.list(for: "cust_TEST000001").count == 2)
        #expect(try await rzp.tokens.fetch("token_TEST000001", for: "cust_TEST000001").token == "FAKETOKENVALUE")
        #expect(try await rzp.tokens.delete("token_TEST000001", for: "cust_TEST000001").deleted)
        let paths = await mock.requests.map(\.path)
        #expect(paths == ["/v1/customers/cust_TEST000001/tokens", "/v1/customers/cust_TEST000001/tokens/token_TEST000001",
                          "/v1/customers/cust_TEST000001/tokens/token_TEST000001"])
    }

    @Test func emptyIDsSendNothing() async {
        let mock = MockTransport()
        await #expect(throws: RazorpayError.self) { try await client(mock).tokens.list(for: "") }
        await #expect(throws: RazorpayError.self) { try await client(mock).tokens.delete("", for: "cust_TEST000001") }
        #expect(await mock.requests.isEmpty)
    }
}

@Suite("Cards")
struct CardTests {
    @Test func fetch() async throws {
        let mock = MockTransport(json: #"{"id":"card_TEST000001","entity":"card","name":"Test User","last4":"1111","network":"RuPay","type":"debit","issuer":"SBIN","international":false,"emi":false,"sub_type":"business"}"#)
        let card = try await client(mock).cards.fetch("card_TEST000001")
        #expect(card.network == .rupay && card.type == .debit && card.subType == "business")
        #expect(await mock.lastRequest?.path == "/v1/cards/card_TEST000001")
    }

    @Test func reference() async throws {
        let mock = MockTransport(json: #"{"network":"Visa","payment_account_reference":"V0010000000000000000000000000","network_reference_id":null}"#)
        let rzp = client(mock)
        let ref = try await rzp.cards.reference(.number("4111 1111 1111 1111"))
        #expect(ref.network == .visa && ref.paymentAccountReference?.hasPrefix("V001") == true && ref.networkReferenceID == nil)
        #expect(try MockTransport.json(await mock.lastRequest?.body)?["number"] as? String == "4111111111111111")
        _ = try await rzp.cards.reference(.token("FAKETOKENVALUE"))
        #expect(try MockTransport.json(await mock.lastRequest?.body)?["tokenised"] as? Bool == true)
        await #expect(throws: RazorpayError.self) { try await rzp.cards.reference(.number(" - ")) }
        #expect(await mock.requests.count == 2)
    }
}
