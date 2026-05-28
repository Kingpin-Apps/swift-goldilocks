// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-goldilocks",
    platforms: [
        .iOS(.v14),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        // Idiomatic Swift API for Ed448, X448, and SHAKE128/256.
        .library(
            name: "Goldilocks",
            targets: ["Goldilocks"]),
        // Raw C surface for consumers that want to skip the Swift wrapper.
        .library(
            name: "CGoldilocks",
            targets: ["CGoldilocks"]),
    ],
    targets: [
        // Vendored libgoldilocks (MIT-licensed Ed448-Goldilocks/libdecaf
        // successor by Mike Hamburg). Self-contained — includes its own
        // Keccak/SHAKE implementation, so it has no external crypto
        // dependencies and builds on every Swift-supported platform.
        .target(
            name: "CGoldilocks",
            path: "Sources/CGoldilocks",
            exclude: ["LICENSE.libgoldilocks.txt"],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("private"),
            ]
        ),
        .target(
            name: "Goldilocks",
            dependencies: ["CGoldilocks"]
        ),
        .testTarget(
            name: "GoldilocksTests",
            dependencies: ["Goldilocks"]
        ),
    ]
)
