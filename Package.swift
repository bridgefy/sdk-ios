// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BridgefySDK",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "BridgefySDK",
            targets: ["BridgefySDK"])
    ],
    targets: [
        .binaryTarget(
            name: "BridgefySDK",
            url: "https://github.com/bridgefy/sdk-ios/releases/download/1.3.2/BridgefySDK.xcframework.zip",
            checksum: "98c6ac14c75fead5b8fff83197d9e3ccd2602d51453a39f8b5dc9c07b98d37fc"
        )
    ]
)
