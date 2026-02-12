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
            url: "https://github.com/bridgefy/sdk-ios/releases/download/1.3.3/BridgefySDK.xcframework.zip",
            checksum: "0d38da2b6072ff89393fe194b09666cddc3e7267a00e532a6709cf2373e56556"
        )
    ]
)
