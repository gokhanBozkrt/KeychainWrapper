// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KeychainWrapper",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "KeychainWrapper",
            targets: ["KeychainWrapper"]
        ),
    ],
    targets: [
        .target(
            name: "KeychainWrapper"
        ),
        .testTarget(
            name: "KeychainWrapperTests",
            dependencies: ["KeychainWrapper"]
        ),
    ]
)
