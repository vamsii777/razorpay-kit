import Foundation
import NIOHTTP1
import Testing
import RazorpayKit
@testable import RazorpayCore

// Sample payloads from the Razorpay API docs (Items, Invoices, Subscriptions, Partners), with fake IDs.
enum BillingFixtures {
    static let item = #"""
    {"id":"item_7Oxp4hmm6T4SCn","active":true,"name":"Book / English August","description":"An indian story, Booker prize winner.","amount":20000,"currency":"INR"}
    """#
    static let planItem = #"""
    {"id":"item_00000000000001","active":true,"name":"Test plan - Weekly","description":"Description for the test plan - Weekly","amount":69900,"unit_amount":69900,"currency":"INR","type":"plan","unit":null,"tax_inclusive":false,"hsn_code":null,"sac_code":null,"tax_rate":null,"tax_id":null,"tax_group_id":null,"created_at":1580219935,"updated_at":1580219935}
    """#
    static let plan = #"""
    {"id":"plan_00000000000001","entity":"plan","interval":1,"period":"weekly","item":\#(planItem),"notes":{"notes_key_1":"Tea, Earl Grey, Hot","notes_key_2":"Tea, Earl Grey… decaf."},"created_at":1580219935}
    """#
    static let subscription = #"""
    {"id":"sub_00000000000001","entity":"subscription","plan_id":"plan_00000000000001","status":"created","current_start":null,"current_end":null,"ended_at":null,"quantity":1,"notes":{"notes_key_1":"Tea, Earl Grey, Hot"},"charge_at":1580453311,"start_at":1580626111,"end_at":1583433000,"auth_attempts":0,"total_count":6,"paid_count":0,"customer_notify":true,"created_at":1580280581,"expire_by":1580626111,"short_url":"https://rzp.io/i/z3b1R61A9","has_scheduled_changes":false,"change_scheduled_at":null,"source":"api","offer_id":"offer_JHD834hjbxzhd38d","remaining_count":5}
    """#
    static let addon = #"""
    {"invoice_id":null,"created_at":1508769839,"entity":"addon","item":{"description":null,"tax_inclusive":false,"tax_group_id":null,"created_at":1508769839,"updated_at":1508769839,"currency":"INR","amount":30000,"unit_amount":30000,"active":true,"tax_id":null,"type":"addon","id":"item_8sg8LTuRkjcVnH","unit":null,"name":"Extra Chair"},"subscription_id":"sub_8RlLljfA4AnDVx","id":"ao_8sg8LU73Y3ieav","quantity":2}
    """#
    static let invoice = #"""
    {"id":"inv_DAweOiQ7amIUVd","entity":"invoice","receipt":"#0961","invoice_number":"#0961","customer_id":"cust_DAtUWmvpktokrT","customer_details":{"id":"cust_DAtUWmvpktokrT","name":"Gaurav Kumar","email":"gaurav.kumar@example.com","contact":"9977886633","gstin":null,"billing_address":null,"shipping_address":null,"customer_name":"Gaurav Kumar","customer_email":"gaurav.kumar@example.com","customer_contact":"9977886633"},"order_id":"order_DBG3P8ZgDd1dsG","line_items":[{"id":"li_DAweOizsysoJU6","item_id":null,"name":"Book / English August - Updated name and quantity","description":"150 points in Quiz","amount":20000,"unit_amount":20000,"gross_amount":20000,"tax_amount":0,"taxable_amount":20000,"net_amount":20000,"currency":"INR","type":"invoice","tax_inclusive":false,"hsn_code":null,"sac_code":null,"tax_rate":null,"unit":null,"quantity":1,"taxes":[]}],"payment_id":null,"status":"issued","expire_by":1567103399,"issued_at":1566974805,"paid_at":null,"cancelled_at":null,"expired_at":null,"sms_status":"sent","email_status":"sent","date":1566891149,"terms":null,"partial_payment":false,"gross_amount":20000,"tax_amount":0,"taxable_amount":20000,"amount":20000,"amount_paid":0,"amount_due":20000,"currency":"INR","currency_symbol":"₹","description":null,"notes":[],"comment":null,"short_url":"https://rzp.io/i/J4tIULG","view_less":true,"billing_start":null,"billing_end":null,"type":"invoice","group_taxes_discounts":false,"created_at":1566906474}
    """#
    // razorpay-go's sample: a draft-like link with customer_* keys, null type and empty line items.
    static let sparseInvoice = #"""
    {"issued_at":1481541533,"customer_details":{"customer_contact":null,"customer_address":null,"customer_email":null,"customer_name":"Old Keys"},"short_url":"http://bit.ly/link","receipt":null,"entity":"invoice","currency":"INR","paid_at":null,"view_less":true,"id":"inv_random_id","customer_id":null,"type":null,"status":"issued","description":"random decsription","order_id":"order_random_id","sms_status":null,"date":1481541533,"payment_id":null,"line_items":[],"notes":[],"amount":100,"email_status":null,"created_at":1481541534}
    """#
    static let accountProduct = #"""
    {"requested_configuration":{"payment_methods":[]},"active_configuration":{"payment_capture":{"mode":"automatic","refund_speed":"normal","automatic_expiry_period":7200},"settlements":{"account_number":null,"ifsc_code":null,"beneficiary_name":null},"notifications":{"whatsapp":true,"sms":false,"email":["test@example.com"]}},"requirements":[{"field_reference":"individual_proof_of_address","resolution_url":"/accounts/acc_HQVlm3bnPmccC0/stakeholders/{stakeholderId}/documents","status":"required","reason_code":"document_missing"},{"field_reference":"settlements.ifsc_code","resolution_url":"/accounts/acc_HQVlm3bnPmccC0/products/acc_prd_HEgNpywUFctQ9f","status":"required","reason_code":"field_missing"}],"tnc":{"id":"tnc_IgohZaDBHRGjPv","accepted":true,"accepted_at":1641550798},"id":"acc_prd_HEgNpywUFctQ9f","account_id":"acc_HQVlm3bnPmccC0","product_name":"payment_links","activation_status":"needs_clarification","requested_at":1625478849}
    """#
    static let terms = #"""
    {"entity":"tnc_map","product_name":"payments","id":"tnc_map_HjOVhIdpVDZ0FB","tnc":{"terms":"https://razorpay.com/terms","privacy":"https://razorpay.com/privacy","agreement":"https://razorpay.com/agreement"},"last_published_at":1640589653}
    """#
}

private func decode<T: Decodable>(_ type: T.Type, _ json: String) throws -> T {
    try RazorpayCoding.decoder.decode(T.self, from: Data(json.utf8))
}

private func client(_ mock: MockTransport) -> RazorpayClient {
    RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
}

private func sent(_ mock: MockTransport) async throws -> [String: Any] {
    try #require(try MockTransport.json(await mock.lastRequest?.body))
}

@Suite("Billing models decode docs samples")
struct BillingModelTests {
    @Test func item() throws {
        let i = try decode(Item.self, BillingFixtures.item)
        #expect(i.id == "item_7Oxp4hmm6T4SCn" && i.active && i.amount == .inr(paise: 20_000))
        #expect(i.type == nil && i.createdAt == nil, "minimal items decode")
        let p = try decode(Item.self, BillingFixtures.planItem)
        #expect(p.type == .plan && p.unitAmount == .inr(paise: 69_900) && p.taxInclusive == false && p.taxRate == nil)
    }

    @Test func invoice() throws {
        let inv = try decode(Invoice.self, BillingFixtures.invoice)
        #expect(inv.id == "inv_DAweOiQ7amIUVd" && inv.status == .issued && inv.type == .invoice)
        #expect(inv.customerID == "cust_DAtUWmvpktokrT" && inv.orderID == "order_DBG3P8ZgDd1dsG")
        #expect(inv.customerDetails?.name == "Gaurav Kumar")
        #expect(inv.amount == .inr(paise: 20_000) && inv.amountDue == .inr(paise: 20_000) && inv.amountPaid == .inr(paise: 0))
        #expect(inv.lineItems.count == 1 && inv.lineItems[0].quantity == 1 && inv.lineItems[0].itemID == nil)
        #expect(inv.smsStatus == .sent && inv.notes.isEmpty && inv.expireBy == Date(timeIntervalSince1970: 1_567_103_399))
    }

    @Test func sparseInvoiceUsesFallbacks() throws {
        let inv = try decode(Invoice.self, BillingFixtures.sparseInvoice)
        #expect(inv.type == nil && inv.lineItems.isEmpty && inv.partialPayment == false)
        #expect(inv.customerDetails?.name == "Old Keys", "customer_name is read when name is absent")
        #expect(inv.amountDue == nil && inv.smsStatus == nil)
    }

    @Test func planSubscriptionAddon() throws {
        let plan = try decode(Plan.self, BillingFixtures.plan)
        #expect(plan.period == .weekly && plan.interval == 1 && plan.item.amount == .inr(paise: 69_900))
        #expect(plan.notes["notes_key_2"] == "Tea, Earl Grey… decaf.")
        let sub = try decode(Subscription.self, BillingFixtures.subscription)
        #expect(sub.planID == "plan_00000000000001" && sub.status == .created && sub.totalCount == 6 && sub.remainingCount == 5)
        #expect(sub.currentStart == nil && sub.offerID == "offer_JHD834hjbxzhd38d" && sub.customerNotify)
        let addon = try decode(Addon.self, BillingFixtures.addon)
        #expect(addon.quantity == 2 && addon.invoiceID == nil && addon.item.type == .addon && addon.subscriptionID == "sub_8RlLljfA4AnDVx")
    }

    @Test func remainingCountAsStringAndUnknownStatus() throws {
        let json = BillingFixtures.subscription
            .replacingOccurrences(of: #""remaining_count":5"#, with: #""remaining_count":"4""#)
            .replacingOccurrences(of: #""status":"created""#, with: #""status":"hibernating""#)
        let sub = try decode(Subscription.self, json)
        #expect(sub.remainingCount == 4 && sub.status.rawValue == "hibernating")
        let plan = try decode(Plan.self, BillingFixtures.plan.replacingOccurrences(of: #""period":"weekly""#, with: #""period":"fortnightly""#))
        #expect(plan.period.rawValue == "fortnightly")
    }

    @Test func accountProductAndTerms() throws {
        let p = try decode(AccountProduct.self, BillingFixtures.accountProduct)
        #expect(p.id == "acc_prd_HEgNpywUFctQ9f" && p.accountID == "acc_HQVlm3bnPmccC0")
        #expect(p.productName == .paymentLinks && p.activationStatus == .needsClarification)
        #expect(p.requirements.count == 2 && p.requirements[1].reasonCode == "field_missing")
        #expect(p.activeConfiguration?["payment_capture"]?["mode"] == "automatic" && p.tnc?.accepted == true)
        let t = try decode(ProductTerms.self, BillingFixtures.terms)
        #expect(t.productName.rawValue == "payments" && t.documents["privacy"] == "https://razorpay.com/privacy")
    }

    @Test func invoiceWebhookEntity() throws {
        #expect(Invoice.payloadKey == "invoice" && Subscription.payloadKey == "subscription")
        #expect(RazorpayWebhook.Name.subscriptionCharged.rawValue == "subscription.charged")
        #expect(RazorpayWebhook.Name.invoicePartiallyPaid.rawValue == "invoice.partially_paid")
    }
}

@Suite("Billing resources")
struct BillingResourceTests {
    @Test func itemCreateUpdateDelete() async throws {
        let mock = MockTransport(json: BillingFixtures.item)
        _ = try await client(mock).items.create(.init(name: "Book", amount: .inr(rupees: 200), description: "d"))
        var r = await mock.lastRequest
        #expect(r?.method == .POST && r?.path == "/v1/items")
        var body = try await sent(mock)
        #expect(body["amount"] as? Int == 20_000 && body["currency"] as? String == "INR")
        _ = try await client(mock).items.update("item_7Oxp4hmm6T4SCn", .init(active: false))
        r = await mock.lastRequest
        body = try await sent(mock)
        #expect(r?.method == .PATCH && body.count == 1 && body["active"] as? Bool == false)
        for reply in ["[]", ""] {
            let del = MockTransport(json: reply)
            try await client(del).items.delete("item_7Oxp4hmm6T4SCn")
            #expect(await del.lastRequest?.method == .DELETE)
        }
    }

    @Test func deleteSurfacesAPIErrors() async throws {
        let mock = MockTransport(status: .badRequest, json: #"{"error":{"code":"BAD_REQUEST_ERROR","description":"Item used in invoice"}}"#)
        do {
            try await client(mock).items.delete("item_1")
            Issue.record("expected an error")
        } catch {
            #expect(error.apiError?.statusCode == 400)
        }
    }

    @Test func rejectsUnsafeIDs() async {
        let mock = MockTransport(json: BillingFixtures.item)
        await #expect(throws: RazorpayError.self) { try await client(mock).items.fetch("item_1/../x") }
        await #expect(throws: RazorpayError.self) { try await client(mock).invoices.issue("") }
        #expect(await mock.requests.isEmpty)
    }

    @Test func invoiceLifecycle() async throws {
        let mock = MockTransport(json: BillingFixtures.invoice)
        let api = client(mock).invoices
        _ = try await api.create(.init(customerID: "cust_1", lineItems: [.item("item_1", quantity: 2), .custom(name: "Fee", amount: .inr(paise: 500))],
                                       expireBy: Date(timeIntervalSince1970: 1_700_000_000), smsNotify: true, draft: true))
        let body = try await sent(mock)
        #expect(body["customer_id"] as? String == "cust_1" && body["draft"] as? String == "1" && body["sms_notify"] as? Int == 1)
        #expect(body["expire_by"] as? Int == 1_700_000_000 && body["type"] as? String == "invoice")
        let lines = try #require(body["line_items"] as? [[String: Any]])
        #expect(lines[0]["item_id"] as? String == "item_1" && lines[0]["quantity"] as? Int == 2 && lines[1]["amount"] as? Int == 500)
        _ = try await api.issue("inv_1")
        #expect(await mock.lastRequest?.path == "/v1/invoices/inv_1/issue")
        _ = try await api.cancel("inv_1")
        #expect(await mock.lastRequest?.path == "/v1/invoices/inv_1/cancel")
        _ = try await api.update("inv_1", .init(notes: ["k": "v"]))
        #expect(try await sent(mock).keys.sorted() == ["notes"])
        let notify = MockTransport(json: #"{"success":true}"#)
        #expect(try await client(notify).invoices.notify("inv_1", by: .email))
        #expect(await notify.lastRequest?.path == "/v1/invoices/inv_1/notify_by/email")
    }

    @Test func listsUseCollections() async throws {
        let mock = MockTransport(json: Fixtures.collection([BillingFixtures.subscription]))
        let subs = try await client(mock).subscriptions.list(.init(filters: ["plan_id": "plan_1"])).collect()
        #expect(subs.count == 1)
        let r = await mock.lastRequest
        #expect(r?.path == "/v1/subscriptions" && r?.query["plan_id"] == "plan_1")
        let plans = MockTransport(json: Fixtures.collection([BillingFixtures.plan]))
        #expect(try await client(plans).plans.list().collect().first?.id == "plan_00000000000001")
        let addons = MockTransport(json: Fixtures.collection([BillingFixtures.addon]))
        #expect(try await client(addons).addons.list().collect().count == 1)
        let invoices = MockTransport(json: Fixtures.collection([BillingFixtures.invoice, BillingFixtures.sparseInvoice]))
        #expect(try await client(invoices).invoices.list().collect().count == 2)
    }

    @Test func subscriptionActions() async throws {
        let mock = MockTransport(json: BillingFixtures.subscription)
        let api = client(mock).subscriptions
        _ = try await api.create(.init(planID: "plan_1", totalCount: 6, addons: [.init(name: "Setup", amount: .inr(paise: 3_000))], notes: ["a": "b"]))
        var body = try await sent(mock)
        #expect(body["plan_id"] as? String == "plan_1" && body["total_count"] as? Int == 6)
        let addon = try #require((body["addons"] as? [[String: Any]])?.first?["item"] as? [String: Any])
        #expect(addon["amount"] as? Int == 3_000 && addon["name"] as? String == "Setup")
        _ = try await api.cancel("sub_1", at: .cycleEnd)
        body = try await sent(mock)
        #expect(body["cancel_at_cycle_end"] as? Int == 1)
        _ = try await api.pause("sub_1")
        #expect(try await sent(mock)["pause_at"] as? String == "now")
        _ = try await api.resume("sub_1")
        #expect(try await sent(mock)["resume_at"] as? String == "now")
        _ = try await api.update("sub_1", .init(quantity: 3, scheduleChangeAt: .cycleEnd))
        body = try await sent(mock)
        #expect(body["schedule_change_at"] as? String == "cycle_end" && body["quantity"] as? Int == 3)
        _ = try await api.scheduledChanges("sub_1")
        #expect(await mock.lastRequest?.path == "/v1/subscriptions/sub_1/retrieve_scheduled_changes")
        _ = try await api.deleteOffer("offer_1", from: "sub_1")
        let r = await mock.lastRequest
        #expect(r?.method == .DELETE && r?.path == "/v1/subscriptions/sub_1/offer_1")
    }

    @Test func invalidBodiesFailBeforeSending() async {
        let mock = MockTransport(json: BillingFixtures.subscription)
        await #expect(throws: RazorpayError.self) { try await client(mock).subscriptions.create(.init(planID: "plan_1", totalCount: 0)) }
        await #expect(throws: RazorpayError.self) {
            try await client(mock).plans.create(.init(period: .monthly, interval: 0, item: .init(name: "P", amount: .inr(paise: 100))))
        }
        await #expect(throws: RazorpayError.self) {
            try await client(mock).addons.create(for: "sub_1", .init(item: .init(name: "A", amount: .inr(paise: 1)), quantity: 0))
        }
        #expect(await mock.requests.isEmpty)
    }

    @Test func addonAndPlanCreate() async throws {
        let mock = MockTransport(json: BillingFixtures.addon)
        _ = try await client(mock).addons.create(for: "sub_8RlLljfA4AnDVx", .init(item: .init(name: "Extra Chair", amount: .inr(paise: 30_000)), quantity: 2))
        #expect(await mock.lastRequest?.path == "/v1/subscriptions/sub_8RlLljfA4AnDVx/addons")
        let plan = MockTransport(json: BillingFixtures.plan)
        _ = try await client(plan).plans.create(.init(period: .weekly, item: .init(name: "W", amount: .inr(paise: 69_900))))
        let body = try await sent(plan)
        #expect(body["period"] as? String == "weekly" && (body["item"] as? [String: Any])?["amount"] as? Int == 69_900)
    }

    @Test func accountProducts() async throws {
        let mock = MockTransport(json: BillingFixtures.accountProduct)
        let api = client(mock).accountProducts
        _ = try await api.request(.init(productName: .paymentGateway, tncAccepted: true, ip: "233.233.233.234"), for: "acc_HQVlm3bnPmccC0")
        #expect(await mock.lastRequest?.path == "/v2/accounts/acc_HQVlm3bnPmccC0/products")
        #expect(try await sent(mock)["product_name"] as? String == "payment_gateway")
        _ = try await api.update("acc_prd_1", account: "acc_1", ["settlements": ["ifsc_code": "HDFC0000317"]])
        let r = await mock.lastRequest
        #expect(r?.method == .PATCH && r?.path == "/v2/accounts/acc_1/products/acc_prd_1")
        let terms = MockTransport(json: BillingFixtures.terms)
        _ = try await client(terms).accountProducts.terms(for: .paymentGateway)
        #expect(await terms.lastRequest?.path == "/v2/products/payment_gateway/tnc")
    }
}
