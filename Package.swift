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
            url: "https://github.com/FranciscoMkdir/SDK-iOS-binary/releases/download/1.2.1/BridgefySDK.xcframework.zip",
            checksum: "5f0c81148c12027c25eeaae3a616b0b7a7f27f38ad7810970480af6f0af1bc07"
        )
    ]
)
