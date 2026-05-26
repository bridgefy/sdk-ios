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
            url: "https://github.com/FranciscoMkdir/SDK-iOS-binary/releases/download/1.0.5/BridgefySDK.xcframework.zip",
            checksum: "f29a0cc0dad250ff82c24f1c8b847b54c32a12baef6dece3101f6e0674914b15"
        )
    ]
)
