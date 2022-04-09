// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import AppleProductTypes

let package: Package = .init(
    name: "KazakusanCore",
    platforms: [.iOS(.v15), .macOS(.v12), .watchOS(.v8), .tvOS(.v15)],
    products: [
        .library(name: "KazakusanCore", type: .dynamic, targets: ["KazakusanCore"])
    ],
    dependencies: [
        
    ],
    targets: [
        .target(name: "KazakusanCore",
                dependencies: [],
                resources: [.process("Resources")]),
        .testTarget(name: "KazakusanCoreTests", dependencies: ["KazakusanCore"], resources: [.process("Resources")])
    ]
)
