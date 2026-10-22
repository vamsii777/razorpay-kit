import Foundation
import Testing
import RazorpayKit
@testable import RazorpayCore

private func event(_ name: String, _ payload: String) throws -> WebhookEvent {
    let body = #"{"entity":"event","account_id":"acc_TEST000001","event":"\#(name)","contains":[],"payload":\#(payload),"created_at":1700000000}"#
    return try RazorpayWebhook.decode(Array(body.utf8)).get().event
}

private func wrap(_ pairs: (String, String)...) -> String {
    "{" + pairs.map { #""\#($0.0)":{"entity":\#($0.1)}"# }.joined(separator: ",") + "}"
}

private let token = #"{"id":"token_TEST000001","entity":"token","method":"upi","recurring":true,"recurring_details":{"status":"confirmed"},"created_at":1700000000}"#

@Suite("WebhookEvent wiring")
struct WebhookWiringTests {
    @Test(arguments: ["token.confirmed", "token.rejected", "token.paused", "token.cancelled"])
    func tokens(name: String) throws {
        let e = try event(name, wrap(("token", token)))
        #expect(e.name == name)
        switch e {
        case .tokenConfirmed(let t), .tokenRejected(let t), .tokenPaused(let t), .tokenCancelled(let t): #expect(t.id == "token_TEST000001")
        default: Issue.record("got \(e)")
        }
    }

    @Test func paymentLinkPaidWithAndWithoutPayment() throws {
        let paid = try event("payment_link.paid", wrap(("payment_link", linkJSON), ("payment", Fixtures.payment), ("order", Fixtures.order)))
        guard case .paymentLinkPaid(let link, let payment) = paid else { Issue.record("got \(paid)"); return }
        #expect(link.id == "plink_TEST000001" && payment?.id == "pay_TEST000001" && paid.payment == payment)
        let partial = try event("payment_link.partially_paid", wrap(("payment_link", linkJSON)))
        guard case .paymentLinkPartiallyPaid(_, nil) = partial else { Issue.record("got \(partial)"); return }
        #expect(try event("payment_link.expired", wrap(("payment_link", linkJSON))).name == "payment_link.expired")
        #expect(try event("payment_link.cancelled", wrap(("payment_link", linkJSON))).name == "payment_link.cancelled")
    }

    @Test func qrAndTransfersAndVirtualAccounts() throws {
        let credited = try event("qr_code.credited", wrap(("qr_code", qrJSON), ("payment", Fixtures.payment)))
        guard case .qrCodeCredited(let q, let p) = credited else { Issue.record("got \(credited)"); return }
        #expect(q.id == "qr_TEST000001" && p != nil)
        #expect(try event("qr_code.closed", wrap(("qr_code", qrJSON))).name == "qr_code.closed")
        for name in ["transfer.processed", "transfer.failed", "transfer.reversed"] {
            #expect(try event(name, wrap(("transfer", transferJSON))).name == name)
        }
        let va = try event("virtual_account.credited", wrap(("virtual_account", vaJSON), ("payment", Fixtures.payment), ("bank_transfer", btJSON)))
        guard case .virtualAccountCredited(_, let pay, let bt) = va else { Issue.record("got \(va)"); return }
        #expect(pay?.id == "pay_TEST000001" && bt?.mode == "NEFT")
        #expect(try event("virtual_account.created", wrap(("virtual_account", vaJSON))).name == "virtual_account.created")
        #expect(try event("virtual_account.closed", wrap(("virtual_account", vaJSON))).name == "virtual_account.closed")
    }

    @Test func missingOrBrokenEntitiesThrow() {
        #expect(throws: RazorpayError.self) { try event("token.confirmed", "{}") }
        #expect(throws: RazorpayError.self) { try event("payment_link.paid", wrap(("payment_link", linkJSON), ("payment", #"{"id":1}"#))) }
        #expect(throws: RazorpayError.self) { try event("transfer.processed", wrap(("transfer", #"{"id":"trf_1"}"#))) }
    }

    @Test func unmodelledStillUnknown() throws {
        let e = try event("fund_account.validation.completed", "{}")
        guard case .unknown(let name, _) = e else { Issue.record("got \(e)"); return }
        #expect(name == "fund_account.validation.completed")
    }
}
