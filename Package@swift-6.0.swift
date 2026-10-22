// swift-tools-version:6.0
import PackageDescription

// Each Razorpay API area is its own module. Depend on just the ones you use, or on
// `RazorpayKit` for everything. Keep this file and Package@swift-6.0.swift in sync
// (scripts/check-manifests.sh enforces it).
let core: [Target.Dependency] = [
    .product(name: "AsyncHTTPClient", package: "async-http-client"),
    .product(name: "NIOCore", package: "swift-nio"),
    .product(name: "NIOHTTP1", package: "swift-nio"),
    .product(name: "NIOFoundationCompat", package: "swift-nio"),
]

/// Feature modules: (name, dependencies on other Razorpay modules).
let features: [(String, [String])] = [
    ("RazorpayPayments", []),
    ("RazorpayOrders", ["RazorpayPayments"]),
    ("RazorpayRefunds", ["RazorpayPayments"]),
    ("RazorpayCustomers", []),
    ("RazorpayItems", []),
    ("RazorpayInvoices", []),
    ("RazorpaySubscriptions", ["RazorpayItems"]),
    ("RazorpayAddons", ["RazorpayItems"]),
    ("RazorpayProducts", []),
    ("RazorpayTokens", ["RazorpayPayments"]),
    ("RazorpayCards", ["RazorpayPayments"]),
    ("RazorpayPaymentLinks", []),
    ("RazorpayQRCodes", ["RazorpayPayments"]),
    ("RazorpayRoute", []),
    ("RazorpaySmartCollect", ["RazorpayPayments"]),
    ("RazorpayLegacy", []),
]

let modules = ["RazorpayCore", "RazorpayVerification"] + features.map(\.0)

var swiftSettings: [SwiftSetting] {
    [
        .enableUpcomingFeature("ExistentialAny"),
    ]
}

let package = Package(
    name: "razorpay-kit",
    platforms: [.macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)],
    products: (modules + ["RazorpayKit"]).map { .library(name: $0, targets: [$0]) },
    dependencies: [
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.62.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", "3.0.0"..<"5.0.0"),
    ],
    targets: [
        .target(name: "RazorpayCore", dependencies: core, swiftSettings: swiftSettings),
        .target(name: "RazorpayVerification", dependencies: [
            "RazorpayCore", .product(name: "Crypto", package: "swift-crypto"),
        ], swiftSettings: swiftSettings),
    ] + features.map { name, deps in
        .target(name: name, dependencies: ["RazorpayCore"] + deps.map { .target(name: $0) }, swiftSettings: swiftSettings)
    } + [
        .target(name: "RazorpayKit", dependencies: modules.map { .target(name: $0) }, swiftSettings: swiftSettings),
        .testTarget(name: "RazorpayKitTests", dependencies: ["RazorpayKit"] + modules.map { .target(name: $0) }, swiftSettings: swiftSettings),
    ],
    swiftLanguageModes: [.v6]
)
