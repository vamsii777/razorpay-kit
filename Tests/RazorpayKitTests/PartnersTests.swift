import Foundation
import NIOHTTP1
import Testing
import RazorpayKit
@testable import RazorpayCore

// Sample payloads from the Razorpay Partners API docs (accounts, webhooks), with fake data.
enum PartnerFixtures {
    static let account = #"""
    { "id": "acc_GRWKk7qQsLnDjX", "type": "standard", "status": "created", "activated_at": null, "live": false, "hold_funds": true, "email": "gauriagain.kumar@example.org", "profile": { "category": "healthcare", "subcategory": "clinic", "addresses": { "registered": { "street1": "507, Koramangala 1st block", "street2": "MG Road", "city": "Bengaluru", "state": "KARNATAKA", "postal_code": 560034, "country": "IN" }, "operation": { "street1": "507, Koramangala 6th block", "street2": "Kormanagalo", "city": "Bengaluru", "state": "KARNATAKA", "country": "IN", "postal_code": 560047 } }, "business_model": "Online Clothing ( men, women, ethnic, modern ) fashion and lifestyle, accessories, t-shirt, shirt, track pant, shoes." }, "notes": { "internal_ref_id": "123123" }, "created_at": 1611136837, "phone": "9000090000", "business_type": "partnership", "legal_business_name": "Acme Corp", "customer_facing_business_name": "Example", "legal_info": { "pan": "AAACL1234C", "gst": "18AABCU9603R1ZM" }, "apps": { "websites": [ "https://www.example.org" ], "android": [ { "url": "playstore.example.org", "name": "Example" } ], "ios": [ { "url": "appstore.example.org", "name": "Example" } ] }, "brand": { "color": "#FFFFFF" }, "contact_info": { "chargeback": { "email": "cb@example.org", "phone": null, "policy_url": null }, "refund": { "email": "cb@example.org", "phone": null, "policy_url": null }, "support": { "email": "support@example.org", "phone": "9999999998", "policy_url": "https://www.google.com" } }}
    """#
    static let webhook = #"""
    { "id": "HK890egfiItP3H", "created_at": 1623060358, "updated_at": 1623060358, "owner_id": "H3kYHQ635sBwXG", "owner_type": "merchant", "context": [], "disabled_at": 0, "url": "https://en1mwkqo5ioct.x.pipedream.net", "alert_email": "gaurav.kumar@example.com", "secret_exists": true, "entity": "webhook", "active": true, "events": [ "payment.authorized", "payment.failed", "payment.captured", "payment.dispute.created", "refund.failed", "refund.created" ] } 
    """#
    // The v1 (own-account) webhook shape: events as a map, disabled_at set.
    static let v1Webhook = #"""
    {"id":"HK890egfiItP3I","url":"https://example.com/hook","entity":"webhook","active":false,"events":{"payment.captured":true,"order.paid":true,"refund.failed":false},"disabled_at":1700000000,"created_at":1623060358}
    """#
}

private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
    try RazorpayCoding.decoder.decode(T.self, from: Data(json.utf8))
}

private func client(_ mock: MockTransport) -> RazorpayClient {
    RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
}

@Suite("Partners: accounts and webhook endpoints")
struct PartnerTests {
    @Test func accountDecodes() throws {
        let a = try decode(Account.self, PartnerFixtures.account)
        #expect(a.id == "acc_GRWKk7qQsLnDjX" && a.type == .standard && a.status == .created && a.holdFunds && !a.live)
        #expect(a.legalBusinessName == "Acme Corp" && a.businessType == "partnership" && a.activatedAt == nil)
        #expect(a.profile?["addresses"]?["registered"]?["postal_code"]?.intValue == 560_034)
        #expect(a.legalInfo?["pan"] == "AAACL1234C" && a.notes["internal_ref_id"] == "123123")
        let odd = try decode(Account.self, PartnerFixtures.account.replacingOccurrences(of: #""status": "created""#, with: #""status": "frozen""#))
        #expect(odd.status.rawValue == "frozen")
    }

    @Test func webhookDecodesBothShapes() throws {
        let v2 = try decode(WebhookEndpoint.self, PartnerFixtures.webhook)
        #expect(v2.id == "HK890egfiItP3H" && v2.active && v2.secretExists && v2.disabledAt == nil)
        #expect(v2.events.count == 6 && v2.events.contains("payment.captured") && v2.ownerType == "merchant")
        let v1 = try decode(WebhookEndpoint.self, PartnerFixtures.v1Webhook)
        #expect(v1.events == ["order.paid", "payment.captured"], "only enabled events, sorted")
        #expect(!v1.active && v1.disabledAt == Date(timeIntervalSince1970: 1_700_000_000) && !v1.secretExists)
    }

    @Test func accountRoutes() async throws {
        let mock = MockTransport(json: PartnerFixtures.account)
        let api = client(mock).accounts
        _ = try await api.create(.init(email: "a@example.org", phone: "9000090000", legalBusinessName: "Acme Corp", businessType: "partnership",
                                       profile: ["category": "healthcare", "subcategory": "clinic"], notes: ["ref": "1"]))
        var r = await mock.lastRequest
        let body = try #require(try MockTransport.json(r?.body))
        #expect(r?.method == .POST && r?.path == "/v2/accounts")
        #expect(body["legal_business_name"] as? String == "Acme Corp" && (body["profile"] as? [String: Any])?["category"] as? String == "healthcare")
        #expect(body["reference_id"] == nil)
        _ = try await api.update("acc_GRWKk7qQsLnDjX", ["customer_facing_business_name": "ABCD Ltd"])
        r = await mock.lastRequest
        #expect(r?.method == .PATCH && r?.path == "/v2/accounts/acc_GRWKk7qQsLnDjX")
        _ = try await api.delete("acc_GRWKk7qQsLnDjX")
        #expect(await mock.lastRequest?.method == .DELETE)
        await #expect(throws: RazorpayError.self) { try await api.fetch("acc_1/../x") }
    }

    @Test func webhookRoutesPickV1OrV2() async throws {
        let mock = MockTransport(json: PartnerFixtures.webhook)
        let api = client(mock).webhookEndpoints
        let create = WebhookEndpoint.Create(url: "https://example.com/hook", events: [.init(rawValue: "payment.captured")], alertEmail: "ops@example.com", secret: "whsec_placeholder")
        _ = try await api.create(create)
        #expect(await mock.lastRequest?.path == "/v1/webhooks")
        _ = try await api.create(create, account: "acc_1")
        #expect(await mock.lastRequest?.path == "/v2/accounts/acc_1/webhooks")
        let body = try #require(try MockTransport.json(await mock.lastRequest?.body))
        #expect(body["events"] as? [String] == ["payment.captured"] && body["alert_email"] as? String == "ops@example.com")
        _ = try await api.update("HK890egfiItP3H", create)
        var r = await mock.lastRequest
        #expect(r?.method == .PUT && r?.path == "/v1/webhooks/HK890egfiItP3H")
        _ = try await api.update("HK890egfiItP3H", account: "acc_1", create)
        r = await mock.lastRequest
        #expect(r?.method == .PATCH && r?.path == "/v2/accounts/acc_1/webhooks/HK890egfiItP3H")
        _ = try await api.fetch("HK890egfiItP3H", account: "acc_1")
        #expect(await mock.lastRequest?.method == .GET)
        let del = MockTransport(json: "[]")
        try await client(del).webhookEndpoints.delete("HK890egfiItP3H", account: "acc_1")
        #expect(await del.lastRequest?.path == "/v2/accounts/acc_1/webhooks/HK890egfiItP3H")
        let list = MockTransport(json: Fixtures.collection([PartnerFixtures.webhook, PartnerFixtures.v1Webhook]))
        #expect(try await client(list).webhookEndpoints.list(account: "acc_1").collect().count == 2)
    }

    @Test func webhookCreateValidatesAndRedacts() async {
        let mock = MockTransport(json: PartnerFixtures.webhook)
        let insecure = WebhookEndpoint.Create(url: "http://example.com", events: ["payment.captured"])
        await #expect(throws: RazorpayError.self) { try await client(mock).webhookEndpoints.create(insecure) }
        await #expect(throws: RazorpayError.self) { try await client(mock).webhookEndpoints.create(.init(url: "https://example.com", events: [])) }
        await #expect(throws: RazorpayError.self) { try await client(mock).webhookEndpoints.fetch("wh_1", account: "") }
        #expect(await mock.requests.isEmpty)
        let secret = WebhookEndpoint.Create(url: "https://example.com", events: ["order.paid"], secret: "whsec_placeholder")
        for text in [String(describing: secret), String(reflecting: secret), String(describing: Mirror(reflecting: secret).children.map(\.value))] {
            #expect(!text.contains("whsec_placeholder"))
        }
    }

    @Test func accountWebhookNames() {
        #expect(Account.payloadKey == "account" && RazorpayWebhook.Name.accountActivated.rawValue == "account.activated")
    }
}
