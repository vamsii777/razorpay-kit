import Foundation
import NIOHTTP1
import Testing
import RazorpayKit
@testable import RazorpayCore

// Sample payloads from the Razorpay Settlements and IIN API docs, with fake IDs.
enum SettlementFixtures {
    static let settlement = #"""
    {"id":"setl_DGlQ1Rj8os78Ec","entity":"settlement","amount":9973635,"status":"processed","fees":471699,"tax":42070,"utr":"1568176960vxp0rj","created_at":1568176960}
    """#
    static let instant = #"""
    {"id":"setlod_FNj7g2YS5J67Rz","entity":"settlement.ondemand","amount_requested":200000,"amount_settled":199410,"amount_pending":0,"amount_reversed":0,"fees":590,"tax":90,"currency":"INR","settle_full_balance":false,"status":"processed","description":"Need this to make vendor payments.","notes":{"notes_key_1":"Tea, Earl Grey, Hot"},"created_at":1596771429}
    """#
    static let instantExpanded = #"""
    {"id":"setlod_FNj7g2YS5J67Rz","entity":"settlement.ondemand","amount_requested":200000,"amount_settled":199410,"amount_pending":0,"amount_reversed":0,"fees":590,"tax":90,"currency":"INR","settle_full_balance":false,"status":"processed","description":null,"notes":[],"created_at":1596771429,"ondemand_payouts":{"entity":"collection","count":1,"items":[{"id":"setlodp_FNj7g2cbvw8ueO","entity":"settlement.ondemand_payout","initiated_at":1596771430,"processed_at":1596778752,"reversed_at":null,"amount":200000,"amount_settled":199410,"fees":590,"tax":90,"utr":"022011173948","status":"processed","created_at":1596771429}]}}
    """#
    static let recon = #"""
    { "entity": "collection", "count": 4, "items": [ { "entity_id": "pay_DEXrnipqTmWVGE", "type": "payment", "debit": 0, "credit": 97100, "amount": 100000, "currency": "INR", "fee": 2900, "tax": 0, "on_hold": false, "settled": true, "created_at": 1567692556, "settled_at": 1568176960, "settlement_id": "setl_DGlQ1Rj8os78Ec", "posted_at": null, "credit_type": "default", "description": "Recurring Payment via Subscription", "notes": "{}", "payment_id": null, "settlement_utr": "1568176960vxp0rj", "order_id": "order_DEXrnRiR3SNDHA", "order_receipt": null, "method": "card", "card_network": "MasterCard", "card_issuer": "KARB", "card_type": "credit", "dispute_id": null }, { "entity_id": "rfnd_DGRcGzZSLyEdg1", "type": "refund", "debit": 242500, "credit": 0, "amount": 242500, "currency": "INR", "fee": 0, "tax": 0, "on_hold": false, "settled": true, "created_at": 1568107224, "settled_at": 1568176960, "settlement_id": "setl_DGlQ1Rj8os78Ec", "posted_at": null, "credit_type": "default", "description": null, "notes": "{}", "payment_id": "pay_DEXq1pACSqFxtS", "settlement_utr": "1568176960vxp0rj", "order_id": "order_DEXpmZgffXNvuI", "order_receipt": null, "method": "card", "card_network": "MasterCard", "card_issuer": "KARB", "card_type": "credit", "dispute_id": null }, { "entity_id": "trf_DEUoCEtdsJgvl7", "type": "transfer", "debit": 100296, "credit": 0, "amount": 100000, "currency": "INR", "fee": 296, "tax": 46, "on_hold": false, "settled": true, "created_at": 1567681786, "settled_at": 1568176960, "settlement_id": "setl_DGlQ1Rj8os78Ec", "posted_at": null, "credit_type": "default", "description": null, "notes": null, "payment_id": "pay_DEApNNTR6xmqJy", "settlement_utr": "1568176960vxp0rj", "order_id": null, "order_receipt": null, "method": null, "card_network": null, "card_issuer": null, "card_type": null, "dispute_id": null }, { "entity_id": "adj_EhcHONhX4ChgNC", "type": "adjustment", "debit": 0, "credit": 1012, "amount": 1012, "currency": "INR", "fee": 0, "tax": 0, "on_hold": false, "settled": true, "created_at": 1567681786, "settled_at": 1568176960, "settlement_id": "setl_DGlQ1Rj8os78Ec", "posted_at": null, "description": "test reason", "notes": null, "payment_id": null, "settlement_utr": null, "order_id": null, "order_receipt": null, "method": null, "card_network": null, "card_issuer": null, "card_type": null, "dispute_id": null } ]}
    """#
    static let iin = #"""
    {"iin":"412345","entity":"iin","network":"Visa","type":"credit","sub_type":"business","issuer_code":"HDFC","issuer_name":"HDFC Bank Ltd","international":false,"is_tokenized":true,"card_iin":"411111","emi":{"available":true},"recurring":{"available":true},"authentication_types":[{"type":"3ds"},{"type":"otp"}]}
    """#
}

private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
    try RazorpayCoding.decoder.decode(T.self, from: Data(json.utf8))
}

private func client(_ mock: MockTransport) -> RazorpayClient {
    RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
}

@Suite("Settlements and IIN")
struct SettlementTests {
    @Test func settlementDecodes() throws {
        let s = try decode(Settlement.self, SettlementFixtures.settlement)
        #expect(s.id == "setl_DGlQ1Rj8os78Ec" && s.status == .processed && s.amount == .inr(paise: 9_973_635))
        #expect(s.fees == .inr(paise: 471_699) && s.utr == "1568176960vxp0rj")
        let unknown = try decode(Settlement.self, SettlementFixtures.settlement.replacingOccurrences(of: "processed", with: "on_hold"))
        #expect(unknown.status.rawValue == "on_hold")
    }

    @Test func instantDecodesWithAndWithoutPayouts() throws {
        let i = try decode(InstantSettlement.self, SettlementFixtures.instant)
        #expect(i.amountRequested == .inr(paise: 200_000) && i.amountSettled == .inr(paise: 199_410) && i.payouts.isEmpty)
        #expect(i.notes["notes_key_1"] == "Tea, Earl Grey, Hot" && !i.settleFullBalance)
        let e = try decode(InstantSettlement.self, SettlementFixtures.instantExpanded)
        #expect(e.payouts.count == 1 && e.payouts[0].utr == "022011173948" && e.payouts[0].reversedAt == nil && e.notes.isEmpty)
    }

    @Test func reconDecodesEveryEntryType() throws {
        let page = try decode(RazorpayCollection<SettlementReconEntry>.self, SettlementFixtures.recon)
        #expect(page.items.map(\.type) == [.payment, .refund, .transfer, .adjustment])
        let pay = page.items[0]
        #expect(pay.entityID == "pay_DEXrnipqTmWVGE" && pay.credit == .inr(paise: 97_100) && pay.fee == .inr(paise: 2_900))
        #expect(pay.notes.isEmpty, "notes sent as the string \"{}\" decode as empty")
        #expect(page.items[1].paymentID == "pay_DEXq1pACSqFxtS" && page.items[1].debit == .inr(paise: 242_500))
        #expect(page.items[3].creditType == nil && page.items[3].settlementUTR == nil)
    }

    @Test func reconNotesAsJSONString() throws {
        let json = #"{"entity_id":"pay_1","type":"payment","amount":1,"currency":"INR","notes":"{\"k\":\"v\",\"n\":3}"}"#
        let entry = try decode(SettlementReconEntry.self, json)
        #expect(entry.notes == ["k": "v", "n": "3"] && !entry.settled && entry.debit == .inr(paise: 0))
    }

    @Test func iinDecodes() throws {
        let iin = try decode(IIN.self, SettlementFixtures.iin)
        #expect(iin.iin == "412345" && iin.type == .credit && iin.isTokenized && iin.cardIIN == "411111")
        #expect(iin.emiAvailable && iin.recurringAvailable && iin.authenticationTypes == ["3ds", "otp"])
        let minimal = try decode(IIN.self, #"{"iin":"999999","type":"charge"}"#)
        #expect(minimal.type?.rawValue == "charge" && !minimal.emiAvailable && minimal.authenticationTypes.isEmpty)
    }

    @Test func settlementRoutes() async throws {
        let mock = MockTransport(json: SettlementFixtures.settlement)
        _ = try await client(mock).settlements.fetch("setl_DGlQ1Rj8os78Ec")
        #expect(await mock.lastRequest?.path == "/v1/settlements/setl_DGlQ1Rj8os78Ec")
        let list = MockTransport(json: Fixtures.collection([SettlementFixtures.settlement]))
        #expect(try await client(list).settlements.list().collect().count == 1)
        #expect(await list.lastRequest?.path == "/v1/settlements")
    }

    @Test func reconSendsPeriodAndPaginates() async throws {
        let mock = MockTransport(json: SettlementFixtures.recon)
        let entries = try await client(mock).settlements.recon(.init(year: 2019, month: 9, day: 11), .init(pageSize: 4, limit: 4)).collect()
        #expect(entries.count == 4)
        let r = await mock.lastRequest
        #expect(r?.path == "/v1/settlements/recon/combined")
        #expect(r?.query["year"] == "2019" && r?.query["month"] == "9" && r?.query["day"] == "11")
    }

    @Test func invalidReconPeriodFailsBeforeSending() async {
        let mock = MockTransport(json: SettlementFixtures.recon)
        await #expect(throws: RazorpayError.self) { try await client(mock).settlements.recon(.init(year: 2024, month: 13)).collect() }
        #expect(await mock.requests.isEmpty)
    }

    @Test func instantRoutes() async throws {
        let mock = MockTransport(json: SettlementFixtures.instant)
        let api = client(mock).settlements
        _ = try await api.createInstant(.init(amount: .inr(rupees: 2_000), description: "vendors", notes: ["k": "v"]))
        var body = try #require(try MockTransport.json(await mock.lastRequest?.body))
        #expect(body["amount"] as? Int == 200_000 && body["settle_full_balance"] as? Bool == false && body["description"] as? String == "vendors")
        _ = try await api.createInstant(.fullBalance())
        body = try #require(try MockTransport.json(await mock.lastRequest?.body))
        #expect(body["amount"] == nil && body["settle_full_balance"] as? Bool == true)
        _ = try await api.fetchInstant("setlod_FNj7g2YS5J67Rz", expandPayouts: true)
        let r = await mock.lastRequest
        #expect(r?.path == "/v1/settlements/ondemand/setlod_FNj7g2YS5J67Rz" && r?.query["expand[]"] == "ondemand_payouts")
        await #expect(throws: RazorpayError.self) { try await api.createInstant(.init(amount: .inr(paise: 0))) }
    }

    @Test func iinRoutesValidateInput() async throws {
        let mock = MockTransport(json: SettlementFixtures.iin)
        _ = try await client(mock).iins.fetch("412345")
        #expect(await mock.lastRequest?.path == "/v1/iins/412345")
        for bad in ["", "12345", "41234a", "4123/5", "1234567890"] {
            await #expect(throws: RazorpayError.self) { try await client(mock).iins.fetch(bad) }
        }
        #expect(await mock.requests.count == 1)
        let list = MockTransport(json: #"{"count":2,"iins":["512967","180005"]}"#)
        #expect(try await client(list).iins.list(flow: .otp) == ["512967", "180005"])
        #expect(await list.lastRequest?.query["flow"] == "otp")
        let empty = MockTransport(json: #"{"count":0,"iins":[]}"#)
        #expect(try await client(empty).iins.list(subType: .business).isEmpty)
        #expect(await empty.lastRequest?.query["sub_type"] == "business")
    }

    @Test func settlementWebhookName() {
        #expect(Settlement.payloadKey == "settlement")
    }
}
