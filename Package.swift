// swift-tools-version: 6.1

import Foundation
import PackageDescription

/// Hack to force Xcode builds to not produce a dylib, since linking fails
/// without a toolset.json specified. Ideally this can be removed if/when
/// Xcode gains toolset.json support.
let xcode = (Context.environment["XPC_SERVICE_NAME"]?.count ?? 0) > 2

let package = Package(
	name: "CrankDefenseForce",
	platforms: [.macOS(.v14)],
	products: [
		.library(name: "CrankDefenseForce", type: xcode ? nil : .dynamic, targets: ["CrankDefenseForce"]),
	],
	dependencies: [
		.package(url: "https://github.com/finnvoor/PlaydateKit.git", branch: "main"),
		.package(url: "https://github.com/strawdynamics/UTF8ViewExtensions.git", branch: "main"),
//		.package(path: "../PlaydateKit"),
//		.package(url: "https://github.com/strawdynamics/PDKMasterPlayer.git", branch: "main"),
//		.package(url: "https://github.com/strawdynamics/PDKPdfxr.git", branch: "main"),
		.package(path: "../PDKMasterPlayer"),
		.package(path: "../PDKPdfxr"),
	],
	targets: [
		.target(
			name: "CrankDefenseForce",
			dependencies: [
				.product(name: "PlaydateKit", package: "PlaydateKit"),
				.product(name: "PDKMasterPlayer", package: "PDKMasterPlayer"),
				.product(name: "PDKPdfxr", package: "PDKPdfxr"),
				.product(name: "UTF8ViewExtensions", package: "UTF8ViewExtensions"),
			],
			exclude: [
				"Resources",
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
				]),
			]
		),
	],
	swiftLanguageModes: [.v6]
)
