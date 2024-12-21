// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "razorpay-kit",
    platforms: [
        .macOS(.v12),
        .iOS(.v15),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "RazorpayKit", targets: ["RazorpayKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.1.0"),
    ],
    targets: [
        .target(name: "RazorpayKit", 
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "RazorpayKitTests",
            dependencies: ["RazorpayKit"],
            swiftSettings: swiftSettings
        ),
    ]
)

var swiftSettings: [SwiftSetting] { 
    [
        .enableUpcomingFeature("StrictConcurrency"),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("FullTypedThrows"),
    ] 
}
