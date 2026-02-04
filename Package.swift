// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-indiclient",
    platforms: [
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "swift-indiclient",
            targets: ["INDIClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.1.4")),
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.89.0")),
        .package(url: "https://github.com/ykimura1970/swift-astronomy.git", .upToNextMajor(from: "1.0.2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "INDIClient",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "DequeModule", package: "swift-collections"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOConcurrencyHelpers", package: "swift-nio"),
                .product(name: "NIOFoundationCompat", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOWebSocket", package: "swift-nio"),
                .product(name: "swift-astronomy", package: "swift-astronomy")
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
