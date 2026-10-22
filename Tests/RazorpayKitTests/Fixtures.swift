// Sample payloads shaped like the Razorpay API docs, with fake IDs and data.
enum Fixtures {
    static let payment = #"""
    {"id":"pay_TEST000001","entity":"payment","amount":50000,"currency":"INR","status":"captured","order_id":"order_TEST000001","invoice_id":null,"international":false,"method":"upi","amount_refunded":0,"refund_status":null,"captured":true,"description":"Test","card_id":null,"bank":null,"wallet":null,"vpa":"test@upi","email":"test@example.com","contact":"+910000000000","notes":[],"fee":1180,"tax":180,"error_code":null,"error_description":null,"error_source":null,"error_step":null,"error_reason":null,"acquirer_data":{"rrn":"000000000001"},"created_at":1700000000}
    """#
    static let failedPayment = #"""
    {"id":"pay_TEST000002","entity":"payment","amount":100,"currency":"INR","status":"failed","method":"card","captured":false,"notes":{"k":"v"},"error_code":"BAD_REQUEST_ERROR","error_description":"Payment failed","error_source":"customer","error_step":"payment_authentication","error_reason":"authentication_failed","created_at":1700000001}
    """#
    static let order = #"""
    {"id":"order_TEST000001","entity":"order","amount":50000,"amount_paid":0,"amount_due":50000,"currency":"INR","receipt":"rcpt_1","offer_id":null,"status":"created","attempts":0,"notes":[],"created_at":1700000000}
    """#
    static let refund = #"""
    {"id":"rfnd_TEST000001","entity":"refund","amount":10000,"currency":"INR","payment_id":"pay_TEST000001","notes":{},"receipt":null,"acquirer_data":{"arn":null},"created_at":1700000100,"batch_id":null,"status":"processed","speed_processed":"normal","speed_requested":"optimum"}
    """#
    static let customer = #"""
    {"id":"cust_TEST000001","entity":"customer","name":"Test User","email":"test@example.com","contact":"+910000000000","gstin":null,"notes":{"source":"app"},"created_at":1700000000}
    """#

    static func collection(_ items: [String]) -> String {
        #"{"entity":"collection","count":\#(items.count),"items":[\#(items.joined(separator: ","))]}"#
    }
}
