// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "INLogger",
    platforms: [.iOS("16.0")],
    products: [
        .library(
            name: "INLogger",
            targets: ["INLogger"]
		),
    ],
    dependencies: [
		.package(url: "https://github.com/indieSoftware/INCommons.git", from: "4.1.0"),
    ],
    targets: [
        .target(
            name: "INLogger",
            dependencies: ["INCommons"]
		),
        .testTarget(
            name: "INLoggerTests",
            dependencies: ["INLogger", "INCommons"]
		),
	],
	swiftLanguageModes: [
		.v5, .version("6")
	]
)
