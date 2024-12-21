import RazorpayKit
import AsyncHTTPClient
import Foundation

/// A client for interacting with the Razorpay API
///
/// Use this actor to access Razorpay's payment services and manage orders.
///
/// ## Overview
/// The Razorpay client provides a Swift interface to Razorpay's payment processing APIs.
/// It handles authentication and provides type-safe access to various API endpoints.
///
/// ```swift
/// let client = RazorpayClient(keyId: "key_id", keySecret: "key_secret") 
/// let razorpay = Razorpay(client)
///
/// // Create an order
/// let order = try await razorpay.orders.create(
///     amount: 10000,
///     currency: "INR"
/// )
/// ```
///
/// ## Topics
/// ### Creating a Client
/// - ``init(_:)``
///
/// ### Available Services
/// - ``orders``
/// - ``razorpayClient``
/// - ``payments``
public actor Razorpay {
    /// The underlying RazorpayKit client used for API requests
    public let razorpayClient: RazorpayClient

    /// Routes for interacting with Razorpay orders
    public let orders: any RazorpayOrderRoutes
    
    /// Routes for interacting with Razorpay payments
    public let payments: any RazorpayPaymentRoutes

    /// Creates a new Razorpay client
    /// - Parameter razorpayClient: The RazorpayKit client to use for API requests
    public init(_ razorpayClient: RazorpayClient) {
        self.razorpayClient = razorpayClient
        self.orders = RazorpayKitOrderRoutes(client: razorpayClient)
        self.payments = RazorpayKitPaymentRoutes(client: razorpayClient)
    }
}