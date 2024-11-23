// https://stackoverflow.com/a/64365354/2690480
extension CaseIterable {
	static func from(string: String) -> Self? { Self.allCases.first { string == "\($0)" } }
	func toString() -> String { "\(self)" }
}
