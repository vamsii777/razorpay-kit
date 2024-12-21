import Testing
import Foundation
@testable import RazorpayKit
@testable import Razorpay
import NIO
import AsyncHTTPClient
import NIOHTTP1

struct RazorpayKitTests {
    var razorpayClient: RazorpayClient
    
    init() async throws {
        guard let apiKey = ProcessInfo.processInfo.environment["RAZORPAY_API_KEY"],
              let apiSecret = ProcessInfo.processInfo.environment["RAZORPAY_API_SECRET"] else {
            throw RazorpayError.invalidResponse("Missing API key or secret")
        }
        razorpayClient = RazorpayClient(
            httpClient: HTTPClient.shared,
            key: apiKey,
            secret: apiSecret
        )
    }
    
    // MARK: - Order Tests
    
    /// Tests successful order creation with all optional parameters
    @Test func createOrderWithFullDetails() async throws {
        let razorpay = Razorpay(razorpayClient)
        let orderRequest = OrderRequest(
            amount: 1000000,
            currency: "INR", 
            receipt: "Receipt#1",
            notes: [
                "customer_name": "John Doe",
                "shipping_address": "123 Main St"
            ],
            partialPayment: true,
            firstPaymentMinAmount: 500000
        )   
        
        let order = try await razorpay.orders.create(orderRequest)
        
        // Verify order details
        #expect(order.amount == 1000000)
        #expect(order.currency == "INR")
        #expect(order.receipt == "Receipt#1")
        #expect(order.status == .created)
        #expect(!order.id.isEmpty)
        #expect(order.amountDue == order.amount)
        #expect(order.amountPaid == 0)
        #expect(order.notes["customer_name"] == "John Doe")
        #expect(order.notes["shipping_address"] == "123 Main St")
    }
    
    /// Tests order creation with minimum required parameters
    @Test func createOrderWithMinimumDetails() async throws {
        let razorpay = Razorpay(razorpayClient)
        let orderRequest = OrderRequest(
            amount: 100,  // Minimum amount (₹1)
            currency: "INR"
        )
        
        let order = try await razorpay.orders.create(orderRequest)
        
        #expect(order.amount == 100)
        #expect(order.currency == "INR")
        #expect(order.status == .created)
        #expect(!order.id.isEmpty)
    }
    
    /// Tests order creation with invalid amount
    @Test func createOrderWithInvalidAmount() async throws {
        let razorpay = Razorpay(razorpayClient)
        let orderRequest = OrderRequest(
            amount: 50,  // Less than minimum amount
            currency: "INR"
        )
        
        await #expect {
            _ = try await razorpay.orders.create(orderRequest)
            return false
        } throws: { error in
            guard let razorpayError = error as? RazorpayError,
                  case .apiError(let apiError) = razorpayError else {
                return false
            }
            
            #expect(apiError.code == .badRequestError)
            #expect(apiError.description.contains("amount"))
            return true
        }
    }
    
    /// Tests order creation with invalid currency
    @Test func createOrderWithInvalidCurrency() async throws {
        let razorpay = Razorpay(razorpayClient)
        let orderRequest = OrderRequest(
            amount: 1000000,
            currency: "INVALID"
        )
        
        await #expect {
            _ = try await razorpay.orders.create(orderRequest)
            return false
        } throws: { error in
            guard let razorpayError = error as? RazorpayError,
                  case .apiError(let apiError) = razorpayError else {
                return false
            }
            
            #expect(apiError.code == .badRequestError)
            #expect(apiError.reason == "input_validation_failed")
            #expect(apiError.description.contains("currency"))
            return true
        }
    }
    
    // MARK: - Payment Tests
    
    /// Tests fetching payment details
    @Test func fetchPayment() async throws {
        let razorpay = Razorpay(razorpayClient)
        
        await #expect {
            _ = try await razorpay.payments.fetch(id: "invalid_payment_id")
            return false
        } throws: { error in
            guard let razorpayError = error as? RazorpayError,
                  case .apiError(let apiError) = razorpayError else {
                return false
            }
            
            #expect(apiError.code == .badRequestError)
            #expect(apiError.description.contains("does not exist"))
            return true
        }
    }
    
    /// Tests fetching payment with expanded card details
    @Test func fetchPaymentWithCardExpansion() async throws {
        let razorpay = Razorpay(razorpayClient)
        
        await #expect {
            _ = try await razorpay.payments.fetch(
                id: "invalid_payment_id",
                expand: [.card]
            )
            return false
        } throws: { error in
            guard let razorpayError = error as? RazorpayError,
                  case .apiError(let apiError) = razorpayError else {
                return false
            }
            
            #expect(apiError.code == .badRequestError)
            #expect(apiError.description.contains("does not exist"))
            return true
        }
    }
    
    /// Tests fetching payments for an order
    @Test func fetchPaymentsForOrder() async throws {
        let razorpay = Razorpay(razorpayClient)
        
        // First create an order
        let order = try await razorpay.orders.create(OrderRequest(
            amount: 1000000,
            currency: "INR"
        ))
        
        // Then fetch its payments
        let payments = try await razorpay.payments.fetchForOrder(id: order.id)
        
        #expect(payments.count == 0) // New order should have no payments
        #expect(payments.entity == "collection")
    }
    
    // MARK: - Authentication Tests
    
    /// Tests authentication with invalid credentials
    @Test func createOrderWithInvalidCredentials() async throws {
        let invalidClient = RazorpayClient(
            httpClient: HTTPClient.shared,
            key: "invalid_key",
            secret: "invalid_secret"
        )
        let razorpay = Razorpay(invalidClient)
        
        let orderRequest = OrderRequest(
            amount: 1000000,
            currency: "INR"
        )
        
        await #expect {
            _ = try await razorpay.orders.create(orderRequest)
            return false
        } throws: { error in
            guard let razorpayError = error as? RazorpayError,
                  case .apiError(let apiError) = razorpayError else {
                return false
            }
            
            #expect(apiError.code == .badRequestError)
            #expect(apiError.description == "Authentication failed")
            return true
        }
    }
}
