// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignSystem",
    defaultLocalization: "sv",
    platforms: [.iOS(.v17)],
    products: [
        
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]),
    ],
    dependencies: [
        .package(url: "https://github.com/matomo-org/matomo-sdk-ios.git", from: "7.5.0"),
        .package(url: "https://github.com/airbnb/lottie-spm.git", from: "4.5.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "MatomoTracker", package: "matomo-sdk-ios"), // Specify the target dependency
                .product(name: "Lottie", package: "lottie-spm")
            ]
        ),
        .testTarget(
            name: "DesignSystem-Tests",
            dependencies: ["DesignSystem"]
        ),
    ]
)

// https://github.com/airbnb/lottie-spm.git
