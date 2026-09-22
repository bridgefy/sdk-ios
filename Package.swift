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
            url: "https://github.com/FranciscoMkdir/SDK-iOS-binary/releases/download/1.2.4/BridgefySDK.xcframework.zip",
            checksum: "4928bf8205dc20fc725f064bf2c5db54c9817c153f1ade9eae9ea67b8a35a9e5"
        )
    ]
)
