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
            url: "https://github.com/bridgefy/sdk-ios/releases/download/1.3.4/BridgefySDK.xcframework.zip",
            checksum: "b89060551556ac7e4bd9c953b81df1a59939696fa8c0e53de19ea48e6a343db5"
        )
    ]
)
