// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RazorpayKit",
    platforms: [
        .macOS(.v13)
    ],
    products: [.library(name: "RazorpayKit", targets: ["RazorpayKit"])],
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.20.1"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "RazorpayKit", dependencies: [
            .product(name: "AsyncHTTPClient", package: "async-http-client"),
            .product(name: "Crypto", package: "swift-crypto"),
        ]),
        .testTarget(
            name: "RazorpayKitTests",
            dependencies: ["RazorpayKit"]),
    ]
)
