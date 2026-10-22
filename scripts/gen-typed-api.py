#!/usr/bin/env python3
"""Generates Sources/RazorpayKit/Typed/Resources.swift.

Every typed method exists twice: `throws(RazorpayError)` for Swift 6 compilers and plain `throws`
for Swift 5.10. Edit the METHODS table below, then run `python3 scripts/gen-typed-api.py`.
"""
import pathlib

# (namespace, doc, signature (no throws/return), return type, body)
METHODS = {
"Payments": ("payments", "Payments: fetch, list, capture, refund. See https://razorpay.com/docs/api/payments/.", [
 ("Fetches a payment.", "fetch(_ id: Payment.ID, options: RequestOptions = .init())", "Payment",
  'try await handler.perform(.GET, "/v1/payments/\\(id.pathComponent().get())", options: options)'),
 ("Lists payments, newest first, fetching pages lazily.", "list(_ list: ListOptions = .init(), options: RequestOptions = .init())", "RazorpayList<Payment>",
  'RazorpayList(handler: handler, path: "/v1/payments", options: list, request: options)'),
 ("Captures an authorized payment. `amount` must equal the authorized amount.", "capture(_ id: Payment.ID, amount: Money, options: RequestOptions = .init())", "Payment",
  'try await handler.perform(.POST, "/v1/payments/\\(id.pathComponent().get())/capture", body: CaptureBody(amount: amount.amount, currency: amount.currency), options: options)'),
 ("Replaces a payment's notes.", "update(_ id: Payment.ID, notes: Notes, options: RequestOptions = .init())", "Payment",
  'try await handler.perform(.PATCH, "/v1/payments/\\(id.pathComponent().get())", body: NotesBody(notes: notes), options: options)'),
 ("Refunds a captured payment, fully by default.", "refund(_ id: Payment.ID, _ refund: Refund.Create = .full, options: RequestOptions = .init())", "Refund",
  'try await handler.perform(.POST, "/v1/payments/\\(id.pathComponent().get())/refund", body: refund, options: options)'),
 ("Lists the refunds of one payment.", "refunds(of id: Payment.ID, _ list: ListOptions = .init(), options: RequestOptions = .init())", "RazorpayList<Refund>",
  'RazorpayList(handler: handler, path: id.pathComponent().map { "/v1/payments/\\($0)/refunds" }, options: list, request: options)'),
]),
"Orders": ("orders", "Orders: create, fetch, list, update. See https://razorpay.com/docs/api/orders/.", [
 ("Creates an order.", "create(_ order: Order.Create, options: RequestOptions = .init())", "Order",
  'try await handler.perform(.POST, "/v1/orders", body: order, options: options)'),
 ("Fetches an order.", "fetch(_ id: Order.ID, options: RequestOptions = .init())", "Order",
  'try await handler.perform(.GET, "/v1/orders/\\(id.pathComponent().get())", options: options)'),
 ("Lists orders, fetching pages lazily.", "list(_ list: ListOptions = .init(), options: RequestOptions = .init())", "RazorpayList<Order>",
  'RazorpayList(handler: handler, path: "/v1/orders", options: list, request: options)'),
 ("Replaces an order's notes.", "update(_ id: Order.ID, notes: Notes, options: RequestOptions = .init())", "Order",
  'try await handler.perform(.PATCH, "/v1/orders/\\(id.pathComponent().get())", body: NotesBody(notes: notes), options: options)'),
 ("Fetches every payment attempt on an order.", "payments(of id: Order.ID, options: RequestOptions = .init())", "[Payment]",
  'try await handler.perform(.GET, "/v1/orders/\\(id.pathComponent().get())/payments", options: options, as: RazorpayCollection<Payment>.self).items'),
]),
"Refunds": ("refunds", "Refunds: fetch, list, update. Create refunds with ``Payments/refund(_:_:options:)``. See https://razorpay.com/docs/api/refunds/.", [
 ("Fetches a refund.", "fetch(_ id: Refund.ID, options: RequestOptions = .init())", "Refund",
  'try await handler.perform(.GET, "/v1/refunds/\\(id.pathComponent().get())", options: options)'),
 ("Lists refunds, fetching pages lazily.", "list(_ list: ListOptions = .init(), options: RequestOptions = .init())", "RazorpayList<Refund>",
  'RazorpayList(handler: handler, path: "/v1/refunds", options: list, request: options)'),
 ("Replaces a refund's notes.", "update(_ id: Refund.ID, notes: Notes, options: RequestOptions = .init())", "Refund",
  'try await handler.perform(.PATCH, "/v1/refunds/\\(id.pathComponent().get())", body: NotesBody(notes: notes), options: options)'),
]),
"Customers": ("customers", "Customers: create, fetch, list, update. See https://razorpay.com/docs/api/customers/.", [
 ("Creates a customer, or returns the existing one with the same email and contact.", "create(_ customer: Customer.Create, options: RequestOptions = .init())", "Customer",
  'try await handler.perform(.POST, "/v1/customers", body: customer, options: options)'),
 ("Fetches a customer.", "fetch(_ id: Customer.ID, options: RequestOptions = .init())", "Customer",
  'try await handler.perform(.GET, "/v1/customers/\\(id.pathComponent().get())", options: options)'),
 ("Lists customers, fetching pages lazily.", "list(_ list: ListOptions = .init(), options: RequestOptions = .init())", "RazorpayList<Customer>",
  'RazorpayList(handler: handler, path: "/v1/customers", options: list, request: options)'),
 ("Updates a customer's name, email or contact.", "update(_ id: Customer.ID, _ changes: Customer.Update, options: RequestOptions = .init())", "Customer",
  'try await handler.perform(.PUT, "/v1/customers/\\(id.pathComponent().get())", body: changes, options: options)'),
]),
}

def method(doc, sig, ret, body, typed):
    lists = ret.startswith("RazorpayList")
    if lists:
        return f"        /// {doc}\n        public func {sig} -> {ret} {{\n            {body}\n        }}\n"
    throws = "throws(RazorpayError)" if typed else "throws"
    asyn = "" if lists else "async "
    return f"        /// {doc}\n        public func {sig} {asyn}{throws} -> {ret} {{\n            {body}\n        }}\n"

out = ["// GENERATED by scripts/gen-typed-api.py. Do not edit by hand.\n", "import Foundation\n", "import NIOHTTP1\n\n"]
out.append("extension RazorpayClient {\n")
for type_name, (prop, doc, _) in METHODS.items():
    out.append(f"    /// {doc}\n    public var {prop}: {type_name} {{ {type_name}(handler: handler) }}\n\n")
for type_name, (_, doc, _) in METHODS.items():
    out.append(f"    /// {doc}\n    public struct {type_name}: Sendable {{\n        let handler: RazorpayAPIHandler\n    }}\n\n")
out.append("}\n")
for typed, cond in ((True, "#if compiler(>=6.0)"), (False, "#else")):
    out.append(f"\n{cond}\n")
    for type_name, (_, _, methods) in METHODS.items():
        out.append(f"\nextension RazorpayClient.{type_name} {{\n")
        out.append("\n".join(method(*m, typed) for m in methods))
        out.append("}\n")
out.append("#endif\n")
out.append('''
struct NotesBody: Encodable, Sendable { let notes: Notes }

struct CaptureBody: Encodable, Sendable {
    let amount: Int
    let currency: Currency
}
''')
pathlib.Path(__file__).resolve().parent.parent.joinpath("Sources/RazorpayKit/Typed/Resources.swift").write_text("".join(out))
