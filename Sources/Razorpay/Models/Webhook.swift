import Foundation

// MARK: - Webhook Event
public struct WebhookEvent: Codable {
    public let entity: String
    public let accountId: String
    public let event: EventType
    public let contains: [String]
    public let payload: Payload
    public let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case entity
        case accountId = "account_id"
        case event
        case contains
        case payload
        case createdAt = "created_at"
    }
}

// MARK: - EventType
public enum EventType: String, Codable {
    case paymentAuthorized = "payment.authorized"
    case paymentCaptured = "payment.captured"
    case paymentFailed = "payment.failed"
    case paymentDowntimeStarted = "payment.downtime.started"
    case paymentDowntimeResolved = "payment.downtime.resolved"
    case paymentDowntimeUpdated = "payment.downtime.updated"
    case orderPaid = "order.paid"
    case refundCreated = "refund.created"
    case refundProcessed = "refund.processed"
    case refundFailed = "refund.failed"
    case refundSpeedChanged = "refund.speed_changed"
}

// MARK: - Payload
public struct Payload: Codable {
    public let payment: PaymentEvent?
    public let paymentDowntime: PaymentDowntimeEvent?
    public let order: OrderEvent?
    public let refund: RefundEvent?

    enum CodingKeys: String, CodingKey {
        case payment
        case paymentDowntime = "payment.downtime"
        case order
        case refund
    }
}

// MARK: - PaymentEvent
public struct PaymentEvent: Codable {
    public let entity: PaymentEntity
}

// MARK: - PaymentEntity
public struct PaymentEntity: Codable {
    public let id: String
    public let entity: String
    public let amount: Int
    public let currency: String
    public let status: String
    public let orderId: String?
    public let invoiceId: String?
    public let international: Bool
    public let method: String
    public let amountRefunded: Int
    public let refundStatus: String?
    public let captured: Bool
    public let description: String?
    public let cardId: String?
    public let bank: String?
    public let wallet: String?
    public let vpa: String?
    public let email: String?
    public let contact: String?
    public let notes: [String: String]?
    public let fee: Int?
    public let tax: Int?
    public let errorCode: String?
    public let errorDescription: String?
    public let errorSource: String?
    public let errorStep: String?
    public let errorReason: String?
    public let acquirerData: AcquirerData?
    public let createdAt: Int
    public let baseAmount: Int?
    public let amountTransferred: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case entity
        case amount
        case currency
        case status
        case orderId = "order_id"
        case invoiceId = "invoice_id"
        case international
        case method
        case amountRefunded = "amount_refunded"
        case refundStatus = "refund_status"
        case captured
        case description
        case cardId = "card_id"
        case bank
        case wallet
        case vpa
        case email
        case contact
        case notes
        case fee
        case tax
        case errorCode = "error_code"
        case errorDescription = "error_description"
        case errorSource = "error_source"
        case errorStep = "error_step"
        case errorReason = "error_reason"
        case acquirerData = "acquirer_data"
        case createdAt = "created_at"
        case baseAmount = "base_amount"
        case amountTransferred = "amount_transferred"
    }
}

// MARK: - PaymentDowntimeEvent
public struct PaymentDowntimeEvent: Codable {
    public let entity: DowntimeEntity
}

// MARK: - DowntimeEntity
public struct DowntimeEntity: Codable {
    public let id: String
    public let entity: String
    public let method: String
    public let begin: Int
    public let end: Int?
    public let status: String
    public let scheduled: Bool
    public let severity: String
    public let instrument: Instrument
    public let instrumentSchema: [String]
    public let createdAt: Int
    public let updatedAt: Int

    enum CodingKeys: String, CodingKey {
        case id
        case entity
        case method
        case begin
        case end
        case status
        case scheduled
        case severity
        case instrument
        case instrumentSchema = "instrument_schema"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Instrument
public struct Instrument: Codable {
    public let bank: String?
}

// MARK: - OrderEvent
public struct OrderEvent: Codable {
    public let entity: OrderEntity
}

// MARK: - OrderEntity
public struct OrderEntity: Codable {
    public let id: String
    public let entity: String
    public let amount: Int
    public let amountPaid: Int
    public let amountDue: Int
    public let currency: String
    public let receipt: String?
    public let offerId: String?
    public let status: String
    public let attempts: Int
    public let notes: [String: String]
    public let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case id
        case entity
        case amount
        case amountPaid = "amount_paid"
        case amountDue = "amount_due"
        case currency
        case receipt
        case offerId = "offer_id"
        case status
        case attempts
        case notes
        case createdAt = "created_at"
    }
}

// MARK: - RefundEvent
public struct RefundEvent: Codable {
    public let entity: RefundEntity
}

// MARK: - RefundEntity
public struct RefundEntity: Codable {
    public let id: String
    public let entity: String
    public let amount: Int
    public let currency: String
    public let paymentId: String
    public let notes: [String: String]?
    public let receipt: String?
    public let acquirerData: AcquirerData?
    public let createdAt: Int
    public let batchId: String?
    public let status: String
    public let speedProcessed: String?
    public let speedRequested: String?

    enum CodingKeys: String, CodingKey {
        case id
        case entity
        case amount
        case currency
        case paymentId = "payment_id"
        case notes
        case receipt
        case acquirerData = "acquirer_data"
        case createdAt = "created_at"
        case batchId = "batch_id"
        case status
        case speedProcessed = "speed_processed"
        case speedRequested = "speed_requested"
    }
} 
