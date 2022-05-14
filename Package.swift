// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QuickAnchors",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "QuickAnchors",
            targets: ["QuickAnchors"]),
    ],
    targets: [
        .target(
            name: "QuickAnchors",
            dependencies: []),
    ]
)
