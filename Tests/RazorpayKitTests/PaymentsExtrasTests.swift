import Foundation
import Testing
import RazorpayKit
@testable import RazorpayCore
@testable import RazorpayPayments

private func client(_ mock: MockTransport) -> RazorpayClient {
    RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret, webhookSecret: WebhookFixtures.secret)
}

private func decode<T: Decodable>(_: T.Type, _ json: String) throws -> T {
    try RazorpayCoding.decoder.decode(T.self, from: Data(json.utf8))
}

private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
    try RazorpayCoding.decoder.decode(T.self, from: RazorpayCoding.encoder.encode(value))
}

/// Docs samples (https://razorpay.com/docs/api/payments/downtime/) with fake IDs.
enum DowntimeSamples {
    static func downtime(method: String = "netbanking", status: String = "started", severity: String = "high",
                         end: String = "null", instrument: String = #"{"bank":"HDFC"}"#, extra: String = "") -> String {
        #"{"id":"down_TEST000001","entity":"payment.downtime","method":"\#(method)","begin":1700000000,"end":\#(end),"status":"\#(status)","scheduled":false,"severity":"\#(severity)","instrument":\#(instrument),"created_at":1700000000,"updated_at":1700000100\#(extra)}"#
    }
}

@Suite("Downtime model")
struct DowntimeModelTests {
    @Test(arguments: [
        (#"{"bank":"HDFC"}"#, "bank"),
        (#"{"issuer":"SBIN","card_type":"credit"}"#, "issuer"),
        (#"{"network":"VISA"}"#, "network"),
        (#"{"vpa_handle":"okhdfcbank"}"#, "vpa"),
        (#"{"psp":"google_pay","flow":"intent"}"#, "psp"),
        (#"{"psp":"google_pay","flow":"in_app"}"#, "turbo"),
    ])
    func instrumentShapes(json: String, shape: String) throws {
        let d = try decode(Downtime.self, DowntimeSamples.downtime(instrument: json))
        let i = d.instrument
        switch shape {
        case "bank": #expect(i.bank == "HDFC")
        case "issuer": #expect(i.issuer == "SBIN" && i.cardType == "credit")
        case "network": #expect(i.network == .visa && !i.isAll)
        case "vpa": #expect(i.vpaHandle == "okhdfcbank")
        case "psp": #expect(i.psp == "google_pay" && i.flow == .intent)
        default: #expect(i.flow == .inApp)
        }
        #expect(i.other.isEmpty)
    }

    @Test func sampleFields() throws {
        let d = try decode(Downtime.self, DowntimeSamples.downtime())
        #expect(d.id == "down_TEST000001" && d.method == .netbanking && d.status == .started && d.severity == .high)
        #expect(d.end == nil, "null end means unknown")
        #expect(d.isOngoing && !d.scheduled)
        #expect(d.begin == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(d.updatedAt == Date(timeIntervalSince1970: 1_700_000_100))
    }

    @Test func scheduledWithEnd() throws {
        let json = DowntimeSamples.downtime(status: "scheduled", end: "1700007200").replacingOccurrences(of: #""scheduled":false"#, with: #""scheduled":true"#)
        let d = try decode(Downtime.self, json)
        #expect(d.scheduled && d.status == .scheduled && !d.isOngoing)
        #expect(d.end == Date(timeIntervalSince1970: 1_700_007_200))
    }

    @Test func unknownValuesSurvive() throws {
        let d = try decode(Downtime.self, DowntimeSamples.downtime(method: "emi", status: "paused", severity: "critical",
                                                                  instrument: #"{"network":"JCB","bank_code":"X"}"#))
        #expect(d.method.rawValue == "emi" && d.status.rawValue == "paused" && d.severity.rawValue == "critical")
        #expect(d.instrument.network?.rawValue == "JCB")
        #expect(d.instrument.other == ["bank_code": "X"], "unmodelled instrument keys are kept")
    }

    @Test func allNetworkAndHandle() throws {
        #expect(try decode(Downtime.self, DowntimeSamples.downtime(method: "card", instrument: #"{"network":"ALL"}"#)).instrument.isAll)
        #expect(try decode(Downtime.self, DowntimeSamples.downtime(method: "upi", instrument: #"{"vpa_handle":"ALL"}"#)).instrument.isAll)
    }

    @Test func missingOptionalFields() throws {
        let json = #"{"id":"down_TEST000002","method":"upi","begin":1700000000,"status":"resolved","severity":"low"}"#
        let d = try decode(Downtime.self, json)
        #expect(d.createdAt == nil && d.updatedAt == nil && d.end == nil && !d.scheduled)
        #expect(d.instrument == .init())
    }

    @Test func webhookShapeIgnoresSchema() throws {
        let d = try decode(Downtime.self, DowntimeSamples.downtime(method: "card", instrument: #"{"issuer":"SBIN","type":"debit"}"#,
                                                                  extra: #","instrument_schema":["issuer","type"]"#))
        #expect(d.instrument.cardType == "debit")
    }

    @Test func codableRoundTrip() throws {
        let d = try decode(Downtime.self, DowntimeSamples.downtime(instrument: #"{"psp":"phonepe","flow":"collect","x":1}"#))
        #expect(try roundTrip(d) == d)
    }

    @Test func garbledThrows() {
        #expect(throws: (any Error).self) { try decode(Downtime.self, "{]") }
        #expect(throws: (any Error).self) { try decode(Downtime.self, #"{"id":"down_1"}"#) }
    }

    @Test func idRejectsBadValues() {
        #expect(throws: RazorpayError.self) { try Downtime.ID("").pathComponent().get() }
        #expect(throws: RazorpayError.self) { try Downtime.ID("down_1/../x").pathComponent().get() }
        #expect(try! roundTrip(Downtime.ID("down_1")) == "down_1")
    }
}

@Suite("Downtime API")
struct DowntimeAPITests {
    @Test func listsDowntimes() async throws {
        let mock = MockTransport(json: #"{"entity":"collection","count":1,"items":[\#(DowntimeSamples.downtime())]}"#)
        let all = try await client(mock).payments.downtimes()
        #expect(all.count == 1 && all[0].instrument.bank == "HDFC")
        let request = await mock.lastRequest
        #expect(request?.method == .GET && request?.path == "/v1/payments/downtimes")
    }

    @Test func emptyCollection() async throws {
        let mock = MockTransport(json: #"{"entity":"collection","count":0,"items":[]}"#)
        #expect(try await client(mock).payments.downtimes().isEmpty)
    }

    @Test func fetchesOne() async throws {
        let mock = MockTransport(json: DowntimeSamples.downtime())
        let d = try await client(mock).payments.downtime("down_TEST000001")
        #expect(d.id == "down_TEST000001")
        #expect(await mock.lastRequest?.path == "/v1/payments/downtimes/down_TEST000001")
    }

    @Test func apiErrorIsTyped() async {
        let mock = MockTransport(status: .badRequest, json: #"{"error":{"code":"BAD_REQUEST_ERROR","description":"The id provided does not exist"}}"#)
        await #expect(throws: RazorpayError.self) { try await client(mock).payments.downtime("down_missing") }
    }

    @Test func emptyIDSendsNothing() async {
        let mock = MockTransport()
        await #expect(throws: RazorpayError.self) { try await client(mock).payments.downtime("") }
        #expect(await mock.requests.isEmpty)
    }

    @Test func garbledBodyIsDecodingError() async {
        let mock = MockTransport(json: "not json")
        do {
            _ = try await client(mock).payments.downtimes()
            Issue.record("expected a decoding error")
        } catch {
            guard case .decoding = error else { Issue.record("got \(error)"); return }
        }
    }
}

@Suite("Downtime webhooks")
struct DowntimeWebhookTests {
    @Test func threeEvents() throws {
        let rzp = client(MockTransport())
        let f = DowntimeWebhookFixtures.self
        let started = try rzp.webhooks.verify(f.started.body, signature: f.started.signature).event
        guard case .downtimeStarted(let d) = started else { Issue.record("got \(started)"); return }
        #expect(d.instrument.issuer == "SBIN" && d.instrument.cardType == "credit" && d.end == nil)
        #expect(started.name == "payment.downtime.started" && started.downtime == d)
        let updated = try rzp.webhooks.verify(f.updated.body, signature: f.updated.signature).event
        #expect(updated.downtime?.severity == .medium && updated.name == RazorpayWebhook.Name.downtimeUpdated.rawValue)
        let resolved = try rzp.webhooks.verify(f.resolved.body, signature: f.resolved.signature).event
        guard case .downtimeResolved(let r) = resolved else { Issue.record("got \(resolved)"); return }
        #expect(r.status == .resolved && r.end != nil)
    }

    @Test func missingEntityOrFieldsIsDecoding() throws {
        let rzp = client(MockTransport())
        for f in [DowntimeWebhookFixtures.missingEntity, DowntimeWebhookFixtures.missingFields] {
            let webhook = try rzp.webhooks.verify(f.body, signature: f.signature)
            do {
                _ = try webhook.event
                Issue.record("expected decoding")
            } catch {
                guard case .decoding = error else { Issue.record("got \(error)"); continue }
            }
        }
    }

    @Test func unknownDowntimeEvent() throws {
        let f = DowntimeWebhookFixtures.unknownEvent
        let event = try client(MockTransport()).webhooks.verify(f.body, signature: f.signature).event
        guard case .unknown(let name, _) = event else { Issue.record("got \(event)"); return }
        #expect(name == "payment.downtime.scheduled_v2")
    }
}

@Suite("Payment extras")
struct PaymentExtrasTests {
    @Test func validateVPA() async throws {
        let mock = MockTransport(json: #"{"vpa":"test@upi","success":true,"customer_name":"Test User"}"#)
        let r = try await client(mock).payments.validateVPA(" test@upi ")
        #expect(r.success && r.customerName == "Test User")
        let request = await mock.lastRequest
        #expect(request?.method == .POST && request?.path == "/v1/payments/validate/vpa")
        #expect(try MockTransport.json(request?.body)?["vpa"] as? String == "test@upi")
    }

    @Test func emptyVPAOrOTPSendsNothing() async {
        let mock = MockTransport()
        await #expect(throws: RazorpayError.self) { try await client(mock).payments.validateVPA("  ") }
        await #expect(throws: RazorpayError.self) { try await client(mock).payments.submitOTP("", for: "pay_TEST000001") }
        await #expect(throws: RazorpayError.self) { try await client(mock).payments.generateOTP(for: "") }
        #expect(await mock.requests.isEmpty)
    }

    @Test func cardDetails() async throws {
        let mock = MockTransport(json: #"{"id":"card_TEST000001","entity":"card","name":"Test User","last4":"1111","network":"Visa","type":"credit","issuer":null,"international":false,"emi":1,"sub_type":"consumer","token_iin":null}"#)
        let card = try await client(mock).payments.card(of: "pay_TEST000001")
        #expect(card.network == .visa && card.type == .credit && card.emi && card.last4 == "1111")
        #expect(await mock.lastRequest?.path == "/v1/payments/pay_TEST000001/card")
        #expect(try roundTrip(card) == card)
    }

    @Test func methods() async throws {
        let mock = MockTransport(json: #"{"entity":"methods","card":true,"debit_card":true,"credit_card":1,"prepaid_card":false,"card_networks":{"AMEX":0,"VISA":1},"netbanking":{"HDFC":"HDFC Bank"},"wallet":{"paytm":true},"emi":false,"upi":true,"paylater":{"lazypay":true}}"#)
        let m = try await client(mock).payments.methods()
        #expect(m.card && m.creditCard && !m.prepaidCard && m.upi && !m.emi)
        #expect(m.cardNetworks == ["AMEX": false, "VISA": true])
        #expect(m.netbanking["HDFC"] == "HDFC Bank" && m.wallets["paytm"] == true)
        #expect(m.raw["paylater"] != nil)
        #expect(await mock.lastRequest?.path == "/v1/methods")
        #expect(try roundTrip(m) == m)
    }

    @Test func createJSONPayment() async throws {
        let mock = MockTransport(json: #"{"razorpay_payment_id":"pay_TEST000001","next":[{"action":"redirect","url":"https://api.razorpay.com/v1/payments/pay_TEST000001/authenticate"},{"action":"otp_generate","url":null}]}"#)
        let req = PaymentRequest(amount: .inr(paise: 50_000), orderID: "order_TEST000001", method: .upi, email: "test@example.com",
                                 contact: "+910000000000", notes: ["k": "v"], details: ["vpa": "test@upi", "amount": 1])
        let r = try await client(mock).payments.create(req, options: .init(idempotencyKey: "pay-1"))
        #expect(r.paymentID == "pay_TEST000001" && r.next.map(\.action) == [.redirect, .otpGenerate] && r.signature == nil)
        let request = await mock.lastRequest
        #expect(request?.path == "/v1/payments/create/json")
        let sent = try #require(try MockTransport.json(request?.body))
        #expect(sent["amount"] as? Int == 50_000, "typed fields win over details")
        #expect(sent["vpa"] as? String == "test@upi" && sent["order_id"] as? String == "order_TEST000001")
        #expect(sent["customer_id"] == nil)
    }

    @Test func recurring() async throws {
        let mock = MockTransport(json: #"{"razorpay_payment_id":"pay_TEST000002","razorpay_order_id":"order_TEST000002","razorpay_signature":"fake_signature"}"#)
        let req = RecurringPaymentRequest(amount: .inr(paise: 1_000), orderID: "order_TEST000002", customerID: "cust_TEST000001",
                                          token: "token_TEST000001", email: "test@example.com", contact: "+910000000000")
        let r = try await client(mock).payments.createRecurring(req)
        #expect(r.orderID == "order_TEST000002" && r.signature == "fake_signature" && r.next.isEmpty)
        let sent = try #require(try MockTransport.json(await mock.lastRequest?.body))
        #expect(sent["recurring"] as? String == "1" && sent["token"] as? String == "token_TEST000001" && sent["notes"] == nil)
        var bad = req; bad.token = " "
        await #expect(throws: RazorpayError.self) { try await client(MockTransport()).payments.createRecurring(bad) }
    }

    @Test func otpFlow() async throws {
        let mock = MockTransport(json: #"{"razorpay_payment_id":"pay_TEST000001","next":[{"action":"otp_submit","url":"https://api.razorpay.com/v1/payments/pay_TEST000001/otp_submit/x"}],"metadata":{"issuer":"HDFC","network":"MC","last4":"1111","iin":"000000"}}"#)
        let rzp = client(mock)
        let g = try await rzp.payments.generateOTP(for: "pay_TEST000001")
        #expect(g.next.first?.action == .otpSubmit && g.metadata["last4"] == "1111")
        _ = try await rzp.payments.resendOTP(for: "pay_TEST000001")
        _ = try await rzp.payments.submitOTP(" 123456 ", for: "pay_TEST000001")
        let paths = await mock.requests.map(\.path)
        #expect(paths == ["/v1/payments/pay_TEST000001/otp_generate", "/v1/payments/pay_TEST000001/otp/resend", "/v1/payments/pay_TEST000001/otp/submit"])
        #expect(try MockTransport.json(await mock.lastRequest?.body)?["otp"] as? String == "123456")
    }

    @Test func extrasAreSendableAndCodable() {
        func check<T: Sendable & Codable & Hashable>(_: T.Type) {}
        check(Downtime.self); check(Card.self); check(PaymentMethods.self); check(VPAValidation.self)
        check(PaymentResult.self); check(PaymentAction.self)
    }
}
