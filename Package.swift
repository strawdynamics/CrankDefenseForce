// swift-tools-version: 6.0

import Foundation
import PackageDescription

let package = Package(
	name: "CrankDefenseForce",
	platforms: [.macOS(.v14)],
	products: [
		.library(name: "CrankDefenseForce", targets: ["CrankDefenseForce"]),
	],
	dependencies: [
		.package(url: "https://github.com/finnvoor/PlaydateKit.git", revision: "87c8b0c")
//		.package(path: "../PlaydateKit")
	],
	targets: [
		.target(
			name: "CrankDefenseForce",
			dependencies: [
				.product(name: "PlaydateKit", package: "PlaydateKit"),
				"SwiftStubs"
			],
			swiftSettings: [
				.enableExperimentalFeature("Embedded"),
				.unsafeFlags([
					"-whole-module-optimization",
					"-Xfrontend", "-disable-objc-interop",
					"-Xfrontend", "-disable-stack-protector",
					"-Xfrontend", "-function-sections",
					"-Xfrontend", "-gline-tables-only",
					"-Xcc", "-DTARGET_EXTENSION",
					"-Xcc", "-I", "-Xcc", "/usr/local/playdate/gcc-arm-none-eabi-9-2019-q4-major/lib/gcc/arm-none-eabi/9.2.1/include",
					"-Xcc", "-I", "-Xcc", "/usr/local/playdate/gcc-arm-none-eabi-9-2019-q4-major/lib/gcc/arm-none-eabi/9.2.1/include-fixed",
					"-Xcc", "-I", "-Xcc", "/usr/local/playdate/gcc-arm-none-eabi-9-2019-q4-major/lib/gcc/arm-none-eabi/9.2.1/../../../../arm-none-eabi/include",
					"-I", "\(Context.environment["PLAYDATE_SDK_PATH"] ?? "\(Context.environment["HOME"]!)/Developer/PlaydateSDK/")/C_API"
				]),
			]
		),
		
		.target(
			name: "SwiftStubs",
			path: "Sources/SwiftStubs"
		)
	],
	swiftLanguageModes: [.v6]
)
