// swift-tools-version:6.0
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
        .library(name: "RazorpayKit", targets: ["RazorpayKit"]),
        .library(name: "Razorpay", targets: ["Razorpay"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.62.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "3.0.0"..<"5.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.112.1")
    ],
    targets: [
        .target(name: "RazorpayKit", 
            dependencies: [
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "Crypto", package: "swift-crypto"),
            ],
            swiftSettings: swiftSettings
        ),
        .target(name: "Razorpay", 
            dependencies: [
                "RazorpayKit",
                .product(name: "Vapor", package: "vapor")
            ],
            swiftSettings: swiftSettings
        ),  
        .testTarget(
            name: "RazorpayKitTests",
            dependencies: ["RazorpayKit"],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "RazorpayTests",
            dependencies: ["RazorpayKit", "Razorpay"],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v6]
)

var swiftSettings: [SwiftSetting] { 
    [
        .enableUpcomingFeature("ExistentialAny"),
    ] 
}
