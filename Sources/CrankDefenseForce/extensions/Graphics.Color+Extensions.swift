import PlaydateKit

extension Graphics.Color {
	static let bayer4x4Matrix: [UInt8] = [
		0,  8, 2, 10,
		12, 4, 14, 6,
		3, 11, 1, 9,
		15, 7, 13, 5
	]
	
	static func getBayer4x4FadePattern(foreground: UInt8, alpha: Float) -> ([UInt8], [UInt8]) {
		Graphics.drawMode = .whiteTransparent
		let cAlpha = alpha.clamped(0.0, 1.0)
		let threshold: UInt8 = UInt8(cAlpha * 16)
		
		var mask: [UInt8] = Array(repeating: 0, count: 8)
		var bitmap: [UInt8] = Array(repeating: 0, count: 8)
		
		for row in 0..<8 {
			var rowBits: UInt8 = 0
			for col in 0..<8 {
				let bayerValue = Self.bayer4x4Matrix[(row % 4) * 4 + (col % 4)]
				
				if bayerValue < threshold {
					rowBits |= (1 << (7 - col))
				}
			}
			mask[row] = rowBits
			
			bitmap[row] = (foreground == 0 ? ~rowBits & 0xFF : rowBits)
		}
		
		return (bitmap, mask)
	}
	
	static func getBayer4x4FadeColor(foreground: UInt8, alpha: Float) -> Graphics.Color {
		let (bitmap, mask) = getBayer4x4FadePattern(foreground: foreground, alpha: alpha)
		
		return .pattern(
			(bitmap[0], bitmap[1], bitmap[2], bitmap[3], bitmap[4], bitmap[5], bitmap[6], bitmap[7]),
			mask: (mask[0], mask[1], mask[2], mask[3], mask[4], mask[5], mask[6], mask[7])
		)
	}
}
