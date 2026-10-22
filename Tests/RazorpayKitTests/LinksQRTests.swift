import Foundation
import Testing
import RazorpayKit
@testable import RazorpayCore
@testable import RazorpayPaymentLinks
@testable import RazorpayQRCodes

private func client(_ mock: MockTransport) -> RazorpayClient {
    RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
}

private func decode<T: Decodable>(_: T.Type, _ json: String) throws -> T {
    try RazorpayCoding.decoder.decode(T.self, from: Data(json.utf8))
}

private func sent(_ mock: MockTransport) async throws -> [String: Any] {
    try #require(try MockTransport.json(await mock.lastRequest?.body))
}

/// From https://razorpay.com/docs/api/payments/payment-links/ with fake IDs.
let linkJSON = #"{"accept_partial":true,"amount":100000,"amount_paid":20000,"callback_method":"","callback_url":"","cancelled_at":0,"created_at":1700000000,"currency":"INR","customer":{"contact":"+910000000000","email":"test@example.com","name":"Test User"},"description":"Payment for policy no #23456","expire_by":0,"expired_at":0,"first_min_partial_amount":10000,"id":"plink_TEST000001","notes":[],"notify":{"email":true,"sms":1},"payments":[{"amount":20000,"created_at":1700000100,"method":"upi","payment_id":"pay_TEST000001","plink_id":"plink_TEST000001","status":"captured","updated_at":1700000100}],"reference_id":"TS1989","reminder_enable":true,"reminders":[],"short_url":"https://rzp.io/i/TEST","status":"partially_paid","updated_at":1700000100,"upi_link":false,"user_id":""}"#

let qrJSON = #"{"id":"qr_TEST000001","entity":"qr_code","created_at":1700000000,"name":"Store Front Display","usage":"single_use","type":"upi_qr","image_url":"https://rzp.io/i/TESTQR","payment_amount":300,"status":"active","description":"For Store 1","fixed_amount":true,"payments_amount_received":0,"payments_count_received":0,"notes":{"purpose":"Test UPI QR Code notes"},"customer_id":"cust_TEST000001","close_by":1900000000,"tax_invoice":[]}"#

@Suite("Payment Links")
struct PaymentLinkTests {
    @Test func decodesDocSample() throws {
        let l = try decode(PaymentLink.self, linkJSON)
        #expect(l.status == .partiallyPaid && l.amount == .inr(paise: 100_000) && l.amountPaid == .inr(paise: 20_000))
        #expect(l.firstMinPartialAmount == .inr(paise: 10_000) && l.acceptPartial)
        #expect(l.callbackURL == nil && l.callbackMethod == nil, "empty strings become nil")
        #expect(l.expireBy == nil && l.cancelledAt == nil, "0 timestamps become nil")
        #expect(l.notify.sms && l.notify.email && !l.notify.whatsapp)
        #expect(l.payments.first?.paymentID == "pay_TEST000001" && l.customer.name == "Test User")
        #expect(try decode(PaymentLink.self, String(decoding: RazorpayCoding.encoder.encode(l), as: UTF8.self)) == l)
    }

    @Test func unknownStatusAndMissingFields() throws {
        let l = try decode(PaymentLink.self, #"{"id":"plink_TEST000002","amount":500,"status":"archived","created_at":1700000000}"#)
        #expect(l.status.rawValue == "archived" && l.payments.isEmpty && l.amountPaid == .inr(paise: 0) && l.notes.isEmpty)
    }

    @Test func createEncodesAndValidates() async throws {
        let mock = MockTransport(json: linkJSON)
        let rzp = client(mock)
        _ = try await rzp.paymentLinks.create(.init(amount: .inr(rupees: 1000), referenceID: "TS1989",
                                                    customer: .init(name: "Test User"), notify: .init(sms: true),
                                                    acceptPartial: true, firstMinPartialAmount: .inr(rupees: 100),
                                                    callbackURL: "https://example.com/cb", notes: ["policy": "x"]))
        let body = try await sent(mock)
        #expect(body["amount"] as? Int == 100_000 && body["currency"] as? String == "INR")
        #expect(body["first_min_partial_amount"] as? Int == 10_000 && body["callback_method"] as? String == "get")
        #expect(body["upi_link"] == nil && (body["notify"] as? [String: Any])?["sms"] as? Bool == true)
        #expect(await mock.lastRequest?.path == "/v1/payment_links")
        for bad in [PaymentLink.Create(amount: .inr(paise: 0)),
                    .init(amount: .inr(paise: 100), firstMinPartialAmount: .inr(paise: 50)),
                    .init(amount: .inr(paise: 100), acceptPartial: true, firstMinPartialAmount: .inr(paise: 500))] {
            await #expect(throws: RazorpayError.self) { try await rzp.paymentLinks.create(bad) }
        }
        #expect(await mock.requests.count == 1)
    }

    @Test func listFetchUpdateCancelNotify() async throws {
        let mock = MockTransport { request in
            let json = request.path.hasSuffix("/notify_by/sms") ? #"{"success":true}"#
                : request.path == "/v1/payment_links" && request.method == .GET ? #"{"payment_links":[\#(linkJSON)]}"# : linkJSON
            return RazorpayHTTPResponse(status: .ok, body: Data(json.utf8))
        }
        let rzp = client(mock)
        #expect(try await rzp.paymentLinks.list(referenceID: "TS1989").count == 1)
        #expect(await mock.lastRequest?.query["reference_id"] == "TS1989")
        _ = try await rzp.paymentLinks.fetch("plink_TEST000001")
        _ = try await rzp.paymentLinks.update("plink_TEST000001", .init(reminderEnable: false))
        #expect(try await sent(mock) as NSDictionary == ["reminder_enable": false])
        _ = try await rzp.paymentLinks.cancel("plink_TEST000001")
        #expect(try await rzp.paymentLinks.notify("plink_TEST000001", via: .sms).success)
        let calls = await mock.requests.map { "\($0.method) \($0.path)" }
        #expect(calls == ["GET /v1/payment_links", "GET /v1/payment_links/plink_TEST000001", "PATCH /v1/payment_links/plink_TEST000001",
                          "POST /v1/payment_links/plink_TEST000001/cancel", "POST /v1/payment_links/plink_TEST000001/notify_by/sms"])
    }

    @Test func emptyListAndBadID() async throws {
        #expect(try await client(MockTransport(json: "{}")).paymentLinks.list().isEmpty)
        let mock = MockTransport()
        await #expect(throws: RazorpayError.self) { try await client(mock).paymentLinks.cancel("") }
        #expect(await mock.requests.isEmpty)
    }
}

@Suite("QR codes")
struct QRCodeTests {
    @Test func decodesDocSample() throws {
        let q = try decode(QRCode.self, qrJSON)
        #expect(q.type == .upi && q.usage == .singleUse && q.status == .active && q.fixedAmount)
        #expect(q.paymentAmount == .inr(paise: 300) && q.paymentsAmountReceived == .inr(paise: 0))
        #expect(q.customerID == "cust_TEST000001" && q.notes["purpose"] != nil && q.closeReason == nil)
        #expect(try decode(QRCode.self, String(decoding: RazorpayCoding.encoder.encode(q), as: UTF8.self)) == q)
    }

    @Test func closedWithUnknownReason() throws {
        let json = qrJSON.replacingOccurrences(of: #""status":"active""#, with: #""status":"closed","close_reason":"fraud","closed_at":1700000500"#)
        let q = try decode(QRCode.self, json)
        #expect(q.status == .closed && q.closeReason?.rawValue == "fraud" && q.closedAt != nil)
    }

    @Test func createListPaymentsClose() async throws {
        let mock = MockTransport { request in
            let json = request.path.hasSuffix("/payments") ? #"{"entity":"collection","count":1,"items":[\#(Fixtures.payment)]}"#
                : request.method == .GET && request.path.hasSuffix("qr_codes") ? #"{"entity":"collection","count":1,"items":[\#(qrJSON)]}"# : qrJSON
            return RazorpayHTTPResponse(status: .ok, body: Data(json.utf8))
        }
        let rzp = client(mock)
        _ = try await rzp.qrCodes.create(.init(usage: .singleUse, name: "Store", paymentAmount: .inr(paise: 300)))
        let body = try await sent(mock)
        #expect(body["fixed_amount"] as? Bool == true && body["payment_amount"] as? Int == 300 && body["type"] as? String == "upi_qr")
        var all: [QRCode] = []
        for try await q in rzp.qrCodes.list(.init(limit: 1)) { all.append(q) }
        #expect(all.count == 1)
        var payments: [Payment] = []
        for try await p in rzp.qrCodes.payments(of: "qr_TEST000001", .init(limit: 1)) { payments.append(p) }
        #expect(payments.first?.id == "pay_TEST000001")
        #expect(try await rzp.qrCodes.close("qr_TEST000001").id == "qr_TEST000001")
        #expect(await mock.lastRequest?.path == "/v1/payments/qr_codes/qr_TEST000001/close")
    }

    @Test func createValidation() async {
        let mock = MockTransport()
        let rzp = client(mock)
        await #expect(throws: RazorpayError.self) { try await rzp.qrCodes.create(.init(usage: .singleUse)) }
        await #expect(throws: RazorpayError.self) { try await rzp.qrCodes.create(.init(usage: .multipleUse, paymentAmount: Money(amount: 100, currency: .usd))) }
        #expect(await mock.requests.isEmpty)
    }
}
