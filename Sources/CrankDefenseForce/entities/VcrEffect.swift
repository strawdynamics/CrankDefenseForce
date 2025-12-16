import PlaydateKit

class VcrEffect: BaseEntity {
	// MARK: Lifecycle

	override init(_ entityStore: EntityStore) {
		let bmp = Graphics.getDisplayBufferBitmap().unsafelyUnwrapped

		let (_, _, rowBytes) = bmp.getData(mask: nil, data: nil)
		self.rowBytes = rowBytes

		super.init(entityStore)
	}

	// MARK: Internal

	var offY = 0

	override func update() {
		uptime += Time.deltaTime

		if uptime >= nextIntensityUpdate {
			updateIntensity()
		}
	}

	override func lateUpdate() {
		let framePtr = Graphics.getFrame().unsafelyUnwrapped

		let rowsToVcr = min(max(0, Display.height + offY), Display.height)

		if rowsToVcr > 0 {
			for y in 0..<rowsToVcr {
				let shiftAmount = Int.random(in: minIntensity...maxIntensity)
				shiftRow(in: framePtr, at: y, by: shiftAmount)
			}

			Graphics.markUpdatedRows(start: 0, end: rowsToVcr - 1)
		}
	}

	// MARK: Private

	private let rowBytes: Int

	private var uptime: Float = 0

	private var minIntensity: Int = 0
	private var maxIntensity: Int = 0

	private var nextIntensityUpdate: Float = 0

	private func updateIntensity() {
		minIntensity = Int.random(in: -3...(-1))
		maxIntensity = Int.random(in: 1...3)
		nextIntensityUpdate = uptime + Float.random(in: 0.1...0.3)
	}

	private func shiftRow(in dataPtr: UnsafeMutablePointer<UInt8>, at row: Int, by pixelShift: Int) {
		let offset = pixelShift % Display.width
		if offset == 0 { return }

		let byteShift = abs(offset) / 8
		let bitShift = abs(offset) % 8
		let forward = offset > 0
		let rowStart = dataPtr.advanced(by: row * rowBytes)

		let tmp = Array(UnsafeBufferPointer(start: rowStart, count: rowBytes))

		for dst in 0..<rowBytes {
			let sourceByteIndex =
				forward
				? dst - byteShift
				: dst + byteShift

			let currentByte: UInt8 =
				(0..<rowBytes).contains(sourceByteIndex)
				? tmp[sourceByteIndex]
				: 0

			guard bitShift != 0 else {
				rowStart[dst] = currentByte
				continue
			}

			let neighborIndex =
				forward
				? sourceByteIndex - 1
				: sourceByteIndex + 1

			let neighbor: UInt8 =
				(0..<rowBytes).contains(neighborIndex)
				? tmp[neighborIndex]
				: 0

			// combine
			let shifted: UInt8
			if forward {
				// Fill high bits from left byte
				shifted = (currentByte >> bitShift) | (neighbor << (8 - bitShift))
			} else {
				// Fill low bits from right byte
				shifted = (currentByte << bitShift) | (neighbor >> (8 - bitShift))
			}
			rowStart[dst] = shifted
		}
	}
}
