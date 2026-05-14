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
            url: "https://github.com/FranciscoMkdir/SDK-iOS-binary/releases/download/1.0.0/BridgefySDK.xcframework.zip",
            checksum: "bdc47013ecb147ae8b8b206f28efab7aa43e64c0fe4377159adf1b63faed6323"
        )
    ]
)
