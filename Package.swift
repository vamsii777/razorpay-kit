// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "razorpay-kit",
    platforms: [
        .macOS(.v13),
        .iOS(.v15),
        .watchOS(.v8),
        .tvOS(.v15),
        .visionOS(.v1)  
    ],
    products: [
        .library(name: "RazorpayKit", targets: ["RazorpayKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.21.2")
    ],
    targets: [
        .target(name: "RazorpayKit", 
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ],
            exclude: ["Documentation.docc"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "RazorpayKitTests",
            dependencies: ["RazorpayKit"],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v5]
)

var swiftSettings: [SwiftSetting] {
    return [
        .enableUpcomingFeature("StrictConcurrency")
    ]
}
