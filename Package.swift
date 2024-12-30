// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "designsystem",
    defaultLocalization: "sv",
    platforms: [.iOS(.v17)],
    products: [
        
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "designsystem",
            targets: ["designsystem"]),
    ],
    dependencies: [
        .package(url: "https://github.com/matomo-org/matomo-sdk-ios.git", from: "7.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "designsystem",
            dependencies: [
                .product(name: "MatomoTracker", package: "matomo-sdk-ios") // Specify the target dependency
            ]),
        .testTarget(
            name: "designsystem-Tests",
            dependencies: ["designsystem"]
        ),
    ]
)
