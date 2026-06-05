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
            url: "https://github.com/bridgefy/sdk-ios/releases/download/1.3.5/BridgefySDK.xcframework.zip",
            checksum: "f2b2fb5b295744f8775a26c2a8773b0593246d5f85f195f7fdbea034799220f7"
        )
    ]
)
