// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "cupertino_native_extra",
    platforms: [
        .iOS("14.0"),
    ],
    products: [
        .library(name: "cupertino_native_extra", targets: ["cupertino_native_extra"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        .target(
            name: "cupertino_native_extra",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
            ]
        ),
    ]
)
