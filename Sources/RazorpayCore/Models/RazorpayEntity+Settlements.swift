// ID tags for settlements. They live in Core so other modules can reference them.
extension RazorpayEntity {
    public enum Settlement {}
    public enum InstantSettlement {}
}

/// `setl_…`. See https://razorpay.com/docs/api/settlements/.
public typealias SettlementID = RazorpayID<RazorpayEntity.Settlement>
/// `setlod_…`, an on-demand (instant) settlement. See https://razorpay.com/docs/api/settlements/instant/.
public typealias InstantSettlementID = RazorpayID<RazorpayEntity.InstantSettlement>
