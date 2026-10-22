// ID tags for the billing areas (Items, Invoices, Plans, Subscriptions, Addons) and partner
// product configurations. They live in Core so modules can reference each other's IDs.
extension RazorpayEntity {
    public enum Item {}
    public enum Invoice {}
    public enum Plan {}
    public enum Subscription {}
    public enum Addon {}
    public enum Offer {}
    public enum Account {}
    public enum AccountProduct {}
}

/// `item_…`. See https://razorpay.com/docs/api/payments/items/.
public typealias ItemID = RazorpayID<RazorpayEntity.Item>
/// `inv_…`. See https://razorpay.com/docs/api/payments/invoices/.
public typealias InvoiceID = RazorpayID<RazorpayEntity.Invoice>
/// `plan_…`. See https://razorpay.com/docs/api/payments/subscriptions/.
public typealias PlanID = RazorpayID<RazorpayEntity.Plan>
/// `sub_…`. See https://razorpay.com/docs/api/payments/subscriptions/.
public typealias SubscriptionID = RazorpayID<RazorpayEntity.Subscription>
/// `ao_…`. See https://razorpay.com/docs/api/payments/subscriptions/.
public typealias AddonID = RazorpayID<RazorpayEntity.Addon>
/// `offer_…`.
public typealias OfferID = RazorpayID<RazorpayEntity.Offer>
/// `acc_…`, a partner sub-merchant or linked account. See https://razorpay.com/docs/api/partners/.
public typealias AccountID = RazorpayID<RazorpayEntity.Account>
/// `acc_prd_…`, a product configuration on an account. See https://razorpay.com/docs/api/partners/product-configuration/.
public typealias AccountProductID = RazorpayID<RazorpayEntity.AccountProduct>
