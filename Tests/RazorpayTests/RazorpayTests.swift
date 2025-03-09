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
            currency: .indianRupee,
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
            currency: .indianRupee
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
            currency: .indianRupee
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
            currency: .init(rawValue: "INVALID")!
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
            currency: .indianRupee
        ))
        
        // Then fetch its payments
        let payments = try await razorpay.payments.fetchForOrder(id: order.id)
        
        #expect(payments.count == 0) // New order should have no payments
        #expect(payments.entity == "collection")
    }
    
    // MARK: - Downtime Tests
    
    /// Tests fetching all payment downtimes
    @Test func fetchAllDowntimes() async throws {
        let razorpay = Razorpay(razorpayClient)
        
        let downtimes = try await razorpay.downtimes.fetchAll()
        
        #expect(downtimes.entity == "collection")
        #expect(downtimes.count ?? 0 >= 0) // Should be 0 or more
        
        // If there are downtimes, verify their structure
        if let firstDowntime = downtimes.items?.first {
            #expect(!(firstDowntime.id?.isEmpty ?? true))
            #expect(firstDowntime.entity == "payment.downtime")
            #expect((firstDowntime.begin ?? 0) > 0)
            #expect(firstDowntime.method != nil)
            #expect(firstDowntime.status != nil)
            #expect(firstDowntime.severity != nil)
            
            // Verify instrument details based on method
            if let method = firstDowntime.method {
                switch method {
                case .card:
                    #expect(firstDowntime.instrument?.issuer != nil || firstDowntime.instrument?.network != nil)
                case .netbanking:
                    #expect(firstDowntime.instrument?.bank != nil)
                case .upi:
                    #expect(firstDowntime.instrument?.vpa != nil || firstDowntime.instrument?.psp != nil)
                case .fpx:
                    #expect(firstDowntime.instrument?.bank != nil)
                case .unknown(let value):
                    print("Found unknown payment method: \(value)")
                    // Test passes for unknown methods without specific validation
                default:
                    // Known methods without specific instrument requirements
                    break
                }
            }
            
            // Print unknown methods for monitoring
            if case .unknown(let value) = firstDowntime.method {
                print("Warning: Encountered unknown payment method: \(value)")
            }
        }
    }
    
    /// Tests fetching a specific payment downtime
    @Test func fetchSpecificDowntime() async throws {
        let razorpay = Razorpay(razorpayClient)
        
        await #expect {
            _ = try await razorpay.downtimes.fetch(id: "invalid_downtime_id")
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
            currency: .indianRupee
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
