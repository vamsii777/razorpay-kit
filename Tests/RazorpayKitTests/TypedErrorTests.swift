import Foundation
import NIOHTTP1
import Testing
@testable import RazorpayKit

private struct Probe: Decodable, Sendable, Equatable { let id: String; let amount: Int }

private func handler(_ mock: MockTransport) -> RazorpayAPIHandler {
    RazorpayAPIHandler(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
}

private struct Boom: Error {}

@Suite("RazorpayError")
struct TypedErrorTests {
    @Test func typedThrowsGivesRazorpayErrorWithoutCasting() async {
        let mock = MockTransport(status: .badRequest, json: #"{"error":{"code":"BAD_REQUEST_ERROR","description":"bad amount","field":"amount","reason":"input_validation_failed","source":"business","step":"NA"}}"#)
        do {
            _ = try await handler(mock).perform(.GET, "/v1/probe", as: Probe.self)
            Issue.record("expected a throw")
        } catch {
            #if compiler(>=6.0)
            let typed: RazorpayError = error  // compiles only because of typed throws
            #else
            let typed = error as! RazorpayError
            #endif
            #expect(typed.statusCode == 400)
            #expect(typed.code == .badRequestError)
            #expect(typed.isInvalidAmount && typed.isValidationFailure)
            #expect(typed.source == "business")
            #expect(typed.step == nil, "\"NA\" is normalised to nil")
            #expect(!typed.isRetryable)
        }
    }

    @Test(arguments: ["", "garbage", "<html>502</html>"])
    func garbledErrorBodiesStillCarryStatus(body: String) async {
        let mock = MockTransport(status: .badGateway, json: body)
        let result = await handler(mock).result(.GET, "/v1/probe", as: Probe.self)
        guard case .failure(.api(let api)) = result else { Issue.record("got \(result)"); return }
        #expect(api.statusCode == 502)
        #expect(RazorpayError.api(api).isRetryable)
    }

    @Test func emptySuccessBodyIsDecodingFailure() async {
        let result = await handler(MockTransport(status: .ok, json: "")).result(.GET, "/v1/probe", as: Probe.self)
        guard case .failure(.decoding(let failure)) = result else { Issue.record("got \(result)"); return }
        #expect(failure.message == "empty body")
        #expect(failure.statusCode == 200)
    }

    @Test func missingFieldNamesThePath() async {
        let result = await handler(MockTransport(json: #"{"id":"x"}"#)).result(.GET, "/v1/probe", as: Probe.self)
        guard case .failure(.decoding(let failure)) = result else { Issue.record("got \(result)"); return }
        #expect(failure.path == "amount")
        #expect(failure.type == "Probe")
        #expect(!failure.description.contains("\"id\""), "body content is never echoed")
    }

    @Test func errorObjectInSuccessBodyIsAPIError() async {
        let result = await handler(MockTransport(json: #"{"error":{"code":"GATEWAY_ERROR","description":"x"}}"#)).result(.GET, "/p", as: Probe.self)
        guard case .failure(let error) = result else { Issue.record("expected failure"); return }
        #expect(error.code == .gatewayError)
    }

    @Test func transportErrorsAreWrappedAndRetryable() async {
        let mock = MockTransport { _ in throw Boom() }
        let result = await handler(mock).result(.GET, "/p", as: Probe.self)
        guard case .failure(let error) = result, case .transport(let underlying) = error else { Issue.record("got \(result)"); return }
        #expect(underlying is Boom)
        #expect(error.isRetryable)
        #expect(!RazorpayError.transport(CancellationError()).isRetryable)
    }

    @Test(arguments: [(408, true), (409, true), (429, true), (500, true), (503, true), (400, false), (401, false), (404, false)])
    func retryability(status: Int, retryable: Bool) {
        #expect(RazorpayError.api(.init(statusCode: status, description: "x")).isRetryable == retryable)
    }

    @Test func requestOptionsHeadersNeverOverrideAuthorization() async throws {
        let mock = MockTransport(json: #"{"id":"a","amount":1}"#)
        let options = RequestOptions(idempotencyKey: "idem-1", accountID: "acc_TEST", headers: ["Authorization": "Basic evil", "Content-Type": "application/json"])
        _ = try await handler(mock).perform(.POST, "/p", options: options, as: Probe.self)
        let request = try #require(await mock.lastRequest)
        #expect(request.headers["Authorization"] == [RazorpayAPIHandler.basicAuthorization(key: TestKeys.key, secret: TestKeys.secret)])
        #expect(request.headers["Content-Type"].count == 1)
        #expect(request.headers.first(name: "X-Razorpay-Idempotency-Key") == "idem-1")
        #expect(request.headers.first(name: "X-Razorpay-Account") == "acc_TEST")
    }

    @Test func descriptionsAreReadable() {
        #expect(RazorpayError.signatureMismatch(.webhook).description == "The webhook signature does not match")
        #expect(RazorpayError.api(.init(statusCode: 400, code: .badRequestError, description: "nope", field: "amount")).description == "HTTP 400 [BAD_REQUEST_ERROR] nope (field: amount)")
    }
}
