struct Utf8Key: Hashable {
	private let utf8Data: [UInt8]

	init(_ string: String) {
		self.utf8Data = Array(string.utf8)

	}

	func hash(into hasher: inout Int) {
		var hash = 0
		let prime = 31
		for byte in utf8Data {
			hash = hash &* prime &+ Int(byte)
		}
		hasher = hash
	}

	static func ==(lhs: Utf8Key, rhs: Utf8Key) -> Bool {
		return lhs.utf8Data == rhs.utf8Data
	}
}
