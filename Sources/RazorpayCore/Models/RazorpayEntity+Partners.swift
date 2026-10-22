// ID tags for partner webhook management. `AccountID` is declared with the billing tags.
extension RazorpayEntity {
    public enum WebhookEndpoint {}
}

/// A registered webhook endpoint's ID. See https://razorpay.com/docs/api/partners/webhooks/.
public typealias WebhookEndpointID = RazorpayID<RazorpayEntity.WebhookEndpoint>
