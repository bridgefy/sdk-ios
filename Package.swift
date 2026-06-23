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
            url: "https://github.com/bridgefy/sdk-ios/releases/download/1.3.6/BridgefySDK.xcframework.zip",
            checksum: "3fca321c9ada60a6c89e46aae3d9f2f1d5b110ef7cf1aa3f5064a724b0cc04cb"
        )
    ]
)
