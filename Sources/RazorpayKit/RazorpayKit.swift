// The umbrella module: `import RazorpayKit` brings in every Razorpay module.
// `@_exported` is used only here, because Swift has no stable way for an umbrella to re-export.
// Feature modules never re-export each other.
@_exported import RazorpayCore
@_exported import RazorpayVerification
@_exported import RazorpayPayments
@_exported import RazorpayOrders
@_exported import RazorpayRefunds
@_exported import RazorpayCustomers
@_exported import RazorpayTokens
@_exported import RazorpayCards
@_exported import RazorpayPaymentLinks
@_exported import RazorpayQRCodes
@_exported import RazorpayRoute
@_exported import RazorpaySmartCollect
@_exported import RazorpayLegacy
