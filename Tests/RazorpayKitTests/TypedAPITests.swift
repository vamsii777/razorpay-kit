import Foundation
import NIOHTTP1
import Testing
import RazorpayKit
@testable import RazorpayCore
@testable import RazorpayVerification

private func client(_ mock: MockTransport) -> RazorpayClient {
    RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
}

private func body(_ request: RazorpayHTTPRequest?) throws -> [String: Any] {
    try #require(try MockTransport.json(request?.body))
}

@Suite("Typed models")
struct TypedModelTests {
    @Test func paymentDecodesDocSample() throws {
        let p = try RazorpayCoding.decoder.decode(Payment.self, from: Data(Fixtures.payment.utf8))
        #expect(p.id == "pay_TEST000001")
        #expect(p.amount == .inr(paise: 50_000))
        #expect(p.status == .captured && p.method == .upi && p.captured)
        #expect(p.orderID == "order_TEST000001")
        #expect(p.fee == .inr(paise: 1_180))
        #expect(p.notes.isEmpty, "notes: [] decodes as empty")
        #expect(p.acquirerData["rrn"] == "000000000001")
        #expect(p.failure == nil)
        #expect(p.createdAt == Date(timeIntervalSince1970: 1_700_000_000))
    }

    @Test func failedPaymentCarriesFailure() throws {
        let p = try RazorpayCoding.decoder.decode(Payment.self, from: Data(Fixtures.failedPayment.utf8))
        #expect(p.status == .failed)
        #expect(p.failure?.reason == "authentication_failed")
        #expect(p.failure?.code == .badRequestError)
        #expect(p.amountRefunded == .inr(paise: 0), "missing amount_refunded defaults to zero")
    }

    @Test func unknownEnumValuesSurvive() throws {
        let json = Fixtures.payment.replacingOccurrences(of: #""status":"captured""#, with: #""status":"teleported""#)
            .replacingOccurrences(of: #""method":"upi""#, with: #""method":"crypto""#)
        let p = try RazorpayCoding.decoder.decode(Payment.self, from: Data(json.utf8))
        #expect(p.status.rawValue == "teleported" && p.method?.rawValue == "crypto")
    }

    @Test func orderRefundCustomerDecode() throws {
        let o = try RazorpayCoding.decoder.decode(Order.self, from: Data(Fixtures.order.utf8))
        #expect(o.amountDue == .inr(paise: 50_000) && o.status == .created && o.receipt == "rcpt_1")
        let r = try RazorpayCoding.decoder.decode(Refund.self, from: Data(Fixtures.refund.utf8))
        #expect(r.paymentID == "pay_TEST000001" && r.status == .processed && r.speedRequested == .optimum)
        #expect(r.acquirerData["arn"] == .null)
        let c = try RazorpayCoding.decoder.decode(Customer.self, from: Data(Fixtures.customer.utf8))
        #expect(c.name == "Test User" && c.notes == ["source": "app"])
    }

    @Test func modelsAreSendableAndHashable() {
        func check<T: Sendable & Hashable>(_: T.Type) {}
        check(Payment.self); check(Order.self); check(Refund.self); check(Customer.self); check(Money.self)
    }
}

@Suite("Typed resources")
struct TypedResourceTests {
    @Test func captureSendsMoneyAndIdempotencyKey() async throws {
        let mock = MockTransport(json: Fixtures.payment)
        let payment = try await client(mock).payments.capture("pay_TEST000001", amount: .inr(paise: 50_000), options: .init(idempotencyKey: "cap-1"))
        #expect(payment.status == .captured)
        let request = await mock.lastRequest
        #expect(request?.method == .POST)
        #expect(request?.path == "/v1/payments/pay_TEST000001/capture")
        #expect(request?.headers.first(name: "X-Razorpay-Idempotency-Key") == "cap-1")
        let sent = try body(request)
        #expect(sent["amount"] as? Int == 50_000 && sent["currency"] as? String == "INR")
    }

    @Test func createOrderEncodesOptionStruct() async throws {
        let mock = MockTransport(json: Fixtures.order)
        let order = try await client(mock).orders.create(.init(amount: .inr(rupees: 500), receipt: "rcpt_1", notes: ["k": "v"]))
        #expect(order.id == "order_TEST000001")
        let sent = try body(await mock.lastRequest)
        #expect(sent["amount"] as? Int == 50_000)
        #expect(sent["receipt"] as? String == "rcpt_1")
        #expect((sent["notes"] as? [String: String]) == ["k": "v"])
        #expect(sent["partial_payment"] == nil, "nil options are omitted")
    }

    @Test func refundDefaultsToFull() async throws {
        let mock = MockTransport(json: Fixtures.refund)
        _ = try await client(mock).payments.refund("pay_TEST000001")
        let request = await mock.lastRequest
        #expect(request?.path == "/v1/payments/pay_TEST000001/refund")
        #expect(try body(request).isEmpty)
        _ = try await client(mock).payments.refund("pay_TEST000001", .partial(.inr(paise: 100), speed: .optimum))
        let partial = try body(await mock.lastRequest)
        #expect(partial["amount"] as? Int == 100 && partial["speed"] as? String == "optimum")
    }

    @Test func emptyIDFailsBeforeNetwork() async {
        let mock = MockTransport(json: Fixtures.payment)
        await #expect(throws: RazorpayError.self) { try await client(mock).payments.fetch("") }
        #expect(await mock.requests.isEmpty)
    }

    @Test func apiErrorSurfacesTyped() async {
        let mock = MockTransport(status: .badRequest, json: #"{"error":{"code":"BAD_REQUEST_ERROR","description":"The id provided does not exist","field":"id"}}"#)
        do {
            _ = try await client(mock).orders.fetch("order_TEST")
            Issue.record("expected throw")
        } catch {
            #expect(error.statusCode == 400 && error.field == "id")
        }
    }

    @Test func customerCreateSendsFailExisting() async throws {
        let mock = MockTransport(json: Fixtures.customer)
        _ = try await client(mock).customers.create(.init(name: "Test User", email: "test@example.com"))
        #expect(try body(await mock.lastRequest)["fail_existing"] as? String == "0")
    }

    @Test func orderPaymentsUnwrapsCollection() async throws {
        let mock = MockTransport(json: Fixtures.collection([Fixtures.payment, Fixtures.failedPayment]))
        let payments = try await client(mock).orders.payments(of: "order_TEST000001")
        #expect(payments.map(\.id) == ["pay_TEST000001", "pay_TEST000002"])
    }
}

@Suite("Pagination")
struct PaginationTests {
    private static func payment(_ n: Int) -> String {
        Fixtures.payment.replacingOccurrences(of: "pay_TEST000001", with: "pay_P\(n)")
    }

    /// Serves `total` payments in pages honouring `count` and `skip`.
    private static func server(total: Int) -> MockTransport {
        MockTransport { request in
            let count = Int(request.query["count"] ?? "10")!
            let skip = Int(request.query["skip"] ?? "0")!
            let items = (skip..<min(skip + count, total)).map(payment)
            return RazorpayHTTPResponse(status: .ok, body: Data(Fixtures.collection(items).utf8))
        }
    }

    @Test(arguments: [0, 1, 99, 100, 101, 250])
    func iteratesEveryPageAndStops(total: Int) async throws {
        let mock = Self.server(total: total)
        var seen: [Payment.ID] = []
        for try await payment in client(mock).payments.list() { seen.append(payment.id) }
        #expect(seen.count == total)
        #expect(Set(seen).count == total)
        let requests = await mock.requests.count
        #expect(requests == total / 100 + 1, "one extra request only when the last page is full")
    }

    @Test func limitAndPageSizeAreRespected() async throws {
        let mock = Self.server(total: 50)
        let items = try await client(mock).payments.list(.init(pageSize: 500, limit: 7)).collect()
        #expect(items.count == 7)
        #expect(await mock.lastRequest?.query["count"] == "7", "page size clamps to 100 and to the remaining limit")
    }

    @Test func filtersAndDatesBecomeQuery() async throws {
        let mock = Self.server(total: 0)
        _ = try await client(mock).orders.list(.init(from: Date(timeIntervalSince1970: 100), to: Date(timeIntervalSince1970: 200), filters: ["receipt": "r1"])).collect()
        let query = await mock.lastRequest?.query
        #expect(query == ["from": "100", "to": "200", "count": "100", "skip": "0", "receipt": "r1"])
    }

    @Test func serverIgnoringSkipDoesNotLoopForever() async throws {
        let page = Fixtures.collection((0..<100).map(Self.payment))
        let mock = MockTransport(json: page)
        let items = try await client(mock).payments.list().collect()
        #expect(items.count == 100)
        #expect(await mock.requests.count == 2)
    }

    @Test func errorMidwayIsTyped() async {
        let mock = MockTransport { request in
            request.query["skip"] == "0"
                ? RazorpayHTTPResponse(status: .ok, body: Data(Fixtures.collection((0..<100).map(Self.payment)).utf8))
                : RazorpayHTTPResponse(status: .tooManyRequests, body: Data())
        }
        do {
            _ = try await client(mock).payments.list().collect()
            Issue.record("expected throw")
        } catch {
            #expect(error.isRateLimited && error.isRetryable)
        }
    }

    @Test func invalidParentIDFailsOnFirstNext() async {
        let mock = Self.server(total: 3)
        await #expect(throws: RazorpayError.self) {
            for try await _ in client(mock).payments.refunds(of: "") {}
        }
        #expect(await mock.requests.isEmpty)
    }
}

@Suite("Raw escape hatch")
struct RawTests {
    @Test func rawGetReturnsJSONValue() async throws {
        let mock = MockTransport(json: #"{"id":"plan_TEST","item":{"amount":500}}"#)
        let plan = try await client(mock).raw.get("/v1/plans/plan_TEST")
        #expect(plan["item"]?["amount"]?.intValue == 500)
        #expect(await mock.lastRequest?.path == "/v1/plans/plan_TEST")
    }

    @Test func rawSendEncodesBodyAndDecodesModels() async throws {
        let mock = MockTransport(json: Fixtures.order)
        let order = try await client(mock).raw.send(.POST, "/v1/orders", body: ["amount": 100, "currency": "INR"], as: Order.self)
        #expect(order.id == "order_TEST000001")
        #expect(try body(await mock.lastRequest)["amount"] as? Int == 100)
    }

    @Test(arguments: ["v1/plans", "//evil.example/v1", "https://evil.example/v1", "/v1/plans?count=1"])
    func rawRejectsHostEscapes(path: String) async {
        let mock = MockTransport()
        await #expect(throws: RazorpayError.self) { try await client(mock).raw.get(path) }
        #expect(await mock.requests.isEmpty)
    }
}

/// Coverage carried over from the removed Vapor `RazorpayTests` target.
@Suite("Carried over from RazorpayTests")
struct CarriedOverTests {
    @Test(arguments: [0, -100])
    func nonPositiveOrderAmountFailsWithoutRequest(paise: Int) async {
        let mock = MockTransport(json: Fixtures.order)
        do {
            _ = try await client(mock).orders.create(.init(amount: .inr(paise: paise)))
            Issue.record("expected throw")
        } catch {
            guard case .invalidRequest = error else { Issue.record("got \(error)"); return }
        }
        #expect(await mock.requests.isEmpty)
    }

    @Test(arguments: [400, 401, 404, 500])
    func typedRoutesThrowOnNon2xx(status: Int) async {
        let mock = MockTransport(status: .init(statusCode: status), json: #"{"error":{"code":"BAD_REQUEST_ERROR","description":"x"}}"#)
        do {
            _ = try await client(mock).orders.fetch("order_TEST000001")
            Issue.record("expected throw")
        } catch {
            #expect(error.statusCode == status)
        }
    }
}
