import Vapor
import RazorpayKit
import AsyncHTTPClient

extension Application {
    private struct RazorpayKey: StorageKey {
        typealias Value = Razorpay
    }

    public var razorpay: Razorpay {
        get {
            if let existing = self.storage[RazorpayKey.self] {
                return existing
            } else {
                fatalError("Razorpay not configured. Configure using app.razorpay = Razorpay(key: <YOUR_KEY>, secret: <YOUR_SECRET>)")
            }
        }
        set {
            self.storage[RazorpayKey.self] = newValue
        }
    }
}

extension Request {
    public var razorpay: Razorpay {
        self.application.razorpay
    }
}

extension Razorpay {
    public init(key: String, secret: String, httpClient: HTTPClient) {
        let razorpayClient = RazorpayClient(httpClient: httpClient, key: key, secret: secret)
        self.init(razorpayClient)
    }

    public init(key: String, secret: String, application: Application) {
        self.init(key: key, secret: secret, httpClient: application.http.client.shared)
    }
}
