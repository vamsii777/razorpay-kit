import XCTest
import Foundation
import NIOHTTP1
import RazorpayKit
@testable import RazorpayCore
@testable import RazorpayLegacy
@testable import RazorpayVerification

final class ErrorTests: XCTestCase {
    private func error(status: HTTPResponseStatus, body: String) async -> RazorpayError? {
        let mock = MockTransport(status: status, json: body)
        let client = RazorpayClient(transport: mock, key: TestKeys.key, secret: TestKeys.secret)
        do {
            _ = try await RazorpayPaymentRoutes(client: client.handler).fetch(paymentID: "pay_TEST", queryParams: nil, extraHeaders: nil)
            return nil
        } catch let error as RazorpayError {
            return error
        } catch {
            XCTFail("unexpected error type: \(type(of: error))")
            return nil
        }
    }

    private func apiError(_ error: RazorpayError?, file: StaticString = #filePath, line: UInt = #line) throws -> RazorpayError.APIError {
        guard case .api(let apiError)? = error else {
            XCTFail("expected .api, got \(String(describing: error))", file: file, line: line)
            throw XCTSkip("no api error")
        }
        return apiError
    }

    func testBadRequest400CarriesStatusAndFields() async throws {
        let body = #"{"error":{"code":"BAD_REQUEST_ERROR","description":"The id provided does not exist","source":"business","step":"payment_initiation","reason":"input_validation_failed","field":"id","metadata":{"order_id":"order_TEST"}}}"#
        let error = await error(status: .badRequest, body: body)
        let api = try apiError(error)
        XCTAssertEqual(error?.statusCode, 400)
        XCTAssertEqual(api.code, .badRequestError)
        XCTAssertEqual(api.description, "The id provided does not exist")
        XCTAssertEqual(api.source, "business")
        XCTAssertEqual(api.step, "payment_initiation")
        XCTAssertEqual(api.reason, "input_validation_failed")
        XCTAssertEqual(api.field, "id")
        XCTAssertEqual(api.metadata, ["order_id": "order_TEST"])
        XCTAssertEqual(error?.isValidationFailure, true)
    }

    func testUnauthorized401() async throws {
        let body = #"{"error":{"code":"BAD_REQUEST_ERROR","description":"Authentication failed"}}"#
        let error = await error(status: .unauthorized, body: body)
        let api = try apiError(error)
        XCTAssertEqual(api.statusCode, 401)
        XCTAssertEqual(error?.isInvalidCredentials, true)
    }

    func testNotFound404HasNoFabricatedFields() async throws {
        let body = #"{"error":{"code":"BAD_REQUEST_ERROR","description":"The requested URL was not found on the server."}}"#
        let api = try apiError(await error(status: .notFound, body: body))
        XCTAssertEqual(api.statusCode, 404)
        XCTAssertNil(api.source)
        XCTAssertNil(api.step)
        XCTAssertNil(api.reason)
        XCTAssertNil(api.field)
        XCTAssertNil(api.metadata)
    }

    func testTooManyRequests429PreservesUnknownCode() async throws {
        let body = #"{"error":{"code":"RATE_LIMIT_EXCEEDED","description":"Too many requests"}}"#
        let api = try apiError(await error(status: .tooManyRequests, body: body))
        XCTAssertEqual(api.statusCode, 429)
        XCTAssertEqual(api.code?.rawValue, "RATE_LIMIT_EXCEEDED")
        XCTAssertNotEqual(api.code, .badRequestError)
    }

    func testServerError500() async throws {
        let body = #"{"error":{"code":"SERVER_ERROR","description":"We are facing some trouble completing your request at the moment."}}"#
        let api = try apiError(await error(status: .internalServerError, body: body))
        XCTAssertEqual(api.statusCode, 500)
        XCTAssertEqual(api.code, .serverError)
    }

    func testMalformedErrorBodyStillThrowsWithStatus() async throws {
        let api = try apiError(await error(status: .badGateway, body: "<html>Bad Gateway</html>"))
        XCTAssertEqual(api.statusCode, 502)
        XCTAssertNil(api.code)
    }

    func testNon2xxWithoutErrorObjectThrows() async throws {
        let api = try apiError(await error(status: .serviceUnavailable, body: #"{"message":"down"}"#))
        XCTAssertEqual(api.statusCode, 503)
    }

    func testMalformedSuccessBodyIsInvalidResponse() async throws {
        let error = await error(status: .ok, body: "not json")
        guard case .decoding(let failure)? = error else {
            return XCTFail("expected .decoding, got \(String(describing: error))")
        }
        XCTAssertEqual(failure.statusCode, 200)
        XCTAssertEqual(error?.statusCode, 200)
    }

    func testErrorCodeRoundTripsUnknownValues() throws {
        let data = Data(#"{"code":"SOMETHING_NEW","description":"x"}"#.utf8)
        let decoded = try JSONDecoder().decode(RazorpayError.APIError.self, from: data)
        XCTAssertEqual(decoded.code?.rawValue, "SOMETHING_NEW")
        let reencoded = try JSONEncoder().encode(decoded)
        XCTAssertTrue(String(decoding: reencoded, as: UTF8.self).contains("SOMETHING_NEW"))
    }

    func testRazorpayErrorIsSendable() {
        func requireSendable<T: Sendable>(_: T.Type) {}
        requireSendable(RazorpayError.self)
    }
}
