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
            url: "https://github.com/FranciscoMkdir/SDK-iOS-binary/releases/download/1.1.8/BridgefySDK.xcframework.zip",
            checksum: "91931c620a62fb7d6c2e52cc0eab88f8be7c83983ac59b1ec4e13288ab31b6f2"
        )
    ]
)
