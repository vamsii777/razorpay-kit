/// Error codes returned by the Razorpay API
///
/// These error codes indicate different types of failures that can occur during API interactions:
/// - ``badRequestError``: Indicates invalid parameters or malformed request
/// - ``gatewayError``: Indicates an error occurred at the payment gateway level
/// - ``serverError``: Indicates an internal server error at Razorpay
enum ErrorCode: String {
    /// Error code indicating invalid parameters or malformed request
    case badRequestError = "BAD_REQUEST_ERROR"
    
    /// Error code indicating a payment gateway level error
    case gatewayError = "GATEWAY_ERROR"
    
    /// Error code indicating an internal Razorpay server error
    case serverError = "SERVER_ERROR"
}
