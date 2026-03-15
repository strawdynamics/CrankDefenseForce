import PlaydateKit
import UTF8ViewExtensions

class PersistentStats {
	// MARK: Lifecycle

	private init() {
		guard let stat = try? File.stat(path: Self.statsPath) else {
			print("[PersistentStats] missing file \(Self.statsPath), using defaults")
			return
		}

		let file = try! File.open(path: Self.statsPath, mode: .readData)

		let fileBuffer = UnsafeMutableRawPointer.allocate(byteCount: Int(stat.size), alignment: 1)

		let bytesRead = try! file.read(buffer: fileBuffer, length: stat.size)
		try! file.close()

		let uint8Buffer = UnsafeBufferPointer<UInt8>(
			start: fileBuffer.assumingMemoryBound(to: UInt8.self), count: bytesRead)
		let jsonString = String(decoding: uint8Buffer, as: Unicode.UTF8.self)

		var decoder = JSON.Decoder()
		decoder.userdata = Unmanaged.passUnretained(self).toOpaque()
		decoder.decodeError = Self.decodeError
		decoder.didDecodeTableValue = Self.didDecodeTableValue
		var value = JSON.Value()

		let didDecode = JSON.decodeString(using: &decoder, jsonString: jsonString, value: &value)

		if didDecode != 1 {
			System.error("Failed to decode persistent stats JSON")
		}
	}

	// MARK: Internal

	static nonisolated(unsafe) let instance = PersistentStats()

	// Cumulative stats
	private(set) var sectorsLost: Int = 0

	private(set) var timePlayed: Float = 0

	private(set) var rocketsLaunched: Int = 0

	private(set) var cpuRocketsDestroyed: Int = 0

	private(set) var cpuFastRocketsDestroyed: Int = 0

	private(set) var cpuSmallUfosDestroyed: Int = 0

	private(set) var cpuBigUfosDestroyed: Int = 0

	private(set) var pauseEnemiesPowerUpsCollected: Int = 0

	private(set) var repairBuildingPowerUpsCollected: Int = 0

	private(set) var destroyEnemiesPowerUpsCollected: Int = 0

	// Record stats
	private(set) var recordTimePlayed: Float = 0
	private(set) var newRecordTimePlayed = false

	private(set) var recordRocketsLaunched: Int = 0
	private(set) var newRecordRocketsLaunched = false

	private(set) var recordCpuRocketsDestroyed: Int = 0
	private(set) var newRecordCpuRocketsDestroyed = false

	private(set) var recordCpuFastRocketsDestroyed: Int = 0
	private(set) var newRecordCpuFastRocketsDestroyed = false

	private(set) var recordCpuSmallUfosDestroyed: Int = 0
	private(set) var newRecordCpuSmallUfosDestroyed = false

	private(set) var recordCpuBigUfosDestroyed: Int = 0
	private(set) var newRecordCpuBigUfosDestroyed = false

	private(set) var recordPauseEnemiesPowerUpsCollected: Int = 0
	private(set) var newRecordPauseEnemiesPowerUpsCollected = false

	private(set) var recordRepairBuildingPowerUpsCollected: Int = 0
	private(set) var newRecordRepairBuildingPowerUpsCollected = false

	private(set) var recordDestroyEnemiesPowerUpsCollected: Int = 0
	private(set) var newRecordDestroyEnemiesPowerUpsCollected = false

	func update(uptime: Float, matchStatsTracker: MatchStatsTracker) {
		updateCumulativeStats(uptime, matchStatsTracker)
		updateRecordStats(uptime, matchStatsTracker)
	}

	func writeToDisk() {
		let file = try! PlaydateKit.File.open(path: Self.statsPath, mode: File.Options.write)
		let ctx = EncodeContext(file: file)

		var encoder = JSON.Encoder()
		JSON.initEncoder(
			encoder: &encoder,
			writeFunc: PersistentStats.writeStringFunc,
			userdata: Unmanaged.passUnretained(ctx).toOpaque(),
			pretty: true,
		)

		encoder.startTable(&encoder)

		// Cumulative
		encoder.addTableMember(&encoder, "sectorsLost", 11)
		encoder.writeInt(&encoder, Int32(sectorsLost))

		encoder.addTableMember(&encoder, "timePlayed", 10)
		encoder.writeDouble(&encoder, Double(timePlayed))

		encoder.addTableMember(&encoder, "rocketsLaunched", 15)
		encoder.writeInt(&encoder, Int32(rocketsLaunched))

		encoder.addTableMember(&encoder, "cpuRocketsDestroyed", 19)
		encoder.writeInt(&encoder, Int32(cpuRocketsDestroyed))

		encoder.addTableMember(&encoder, "cpuFastRocketsDestroyed", 23)
		encoder.writeInt(&encoder, Int32(cpuFastRocketsDestroyed))

		encoder.addTableMember(&encoder, "cpuSmallUfosDestroyed", 21)
		encoder.writeInt(&encoder, Int32(cpuSmallUfosDestroyed))

		encoder.addTableMember(&encoder, "cpuBigUfosDestroyed", 19)
		encoder.writeInt(&encoder, Int32(cpuBigUfosDestroyed))

		encoder.addTableMember(&encoder, "pauseEnemiesPowerUpsCollected", 29)
		encoder.writeInt(&encoder, Int32(pauseEnemiesPowerUpsCollected))

		encoder.addTableMember(&encoder, "repairBuildingPowerUpsCollected", 31)
		encoder.writeInt(&encoder, Int32(repairBuildingPowerUpsCollected))

		encoder.addTableMember(&encoder, "destroyEnemiesPowerUpsCollected", 31)
		encoder.writeInt(&encoder, Int32(destroyEnemiesPowerUpsCollected))

		// Records
		encoder.addTableMember(&encoder, "recordTimePlayed", 16)
		encoder.writeDouble(&encoder, Double(recordTimePlayed))

		encoder.addTableMember(&encoder, "recordRocketsLaunched", 21)
		encoder.writeInt(&encoder, Int32(recordRocketsLaunched))

		encoder.addTableMember(&encoder, "recordCpuRocketsDestroyed", 25)
		encoder.writeInt(&encoder, Int32(recordCpuRocketsDestroyed))

		encoder.addTableMember(&encoder, "recordCpuFastRocketsDestroyed", 29)
		encoder.writeInt(&encoder, Int32(recordCpuFastRocketsDestroyed))

		encoder.addTableMember(&encoder, "recordCpuSmallUfosDestroyed", 27)
		encoder.writeInt(&encoder, Int32(recordCpuSmallUfosDestroyed))

		encoder.addTableMember(&encoder, "recordCpuBigUfosDestroyed", 25)
		encoder.writeInt(&encoder, Int32(recordCpuBigUfosDestroyed))

		encoder.addTableMember(&encoder, "recordPauseEnemiesPowerUpsCollected", 35)
		encoder.writeInt(&encoder, Int32(recordPauseEnemiesPowerUpsCollected))

		encoder.addTableMember(&encoder, "recordRepairBuildingPowerUpsCollected", 37)
		encoder.writeInt(&encoder, Int32(recordRepairBuildingPowerUpsCollected))

		encoder.addTableMember(&encoder, "recordDestroyEnemiesPowerUpsCollected", 37)
		encoder.writeInt(&encoder, Int32(recordDestroyEnemiesPowerUpsCollected))

		encoder.endTable(&encoder)

		try! file.close()
	}

	// MARK: Private

	private func updateCumulativeStats(_ uptime: Float, _ matchStatsTracker: MatchStatsTracker) {
		sectorsLost += 1
		timePlayed += uptime

		rocketsLaunched += matchStatsTracker.rocketsLaunched

		cpuRocketsDestroyed += matchStatsTracker.cpuRocketsDestroyed
		cpuFastRocketsDestroyed += matchStatsTracker.cpuFastRocketsDestroyed
		cpuSmallUfosDestroyed += matchStatsTracker.cpuSmallUfosDestroyed
		cpuBigUfosDestroyed += matchStatsTracker.cpuBigUfosDestroyed

		pauseEnemiesPowerUpsCollected += matchStatsTracker.pauseEnemiesPowerUpsCollected
		repairBuildingPowerUpsCollected += matchStatsTracker.repairBuildingPowerUpsCollected
		destroyEnemiesPowerUpsCollected += matchStatsTracker.destroyEnemiesPowerUpsCollected
	}

	private func updateRecordStats(_ uptime: Float, _ matchStatsTracker: MatchStatsTracker) {
		if uptime > recordTimePlayed {
			recordTimePlayed = uptime
			newRecordTimePlayed = true

			let _ = Scoreboards.addScore(boardID: CdfScoreboard.toptimes.rawValue, value: CUnsignedInt(uptime)) { score, errorMessage in

				if let errorMessage {
					print("addScore error: \(String(cString: errorMessage))")
					return
				}
			}
		} else {
			newRecordTimePlayed = false
		}

		if matchStatsTracker.rocketsLaunched > recordRocketsLaunched {
			recordRocketsLaunched = matchStatsTracker.rocketsLaunched
			newRecordRocketsLaunched = true
		} else {
			newRecordRocketsLaunched = false
		}

		if matchStatsTracker.cpuRocketsDestroyed > recordCpuRocketsDestroyed {
			recordCpuRocketsDestroyed = matchStatsTracker.cpuRocketsDestroyed
			newRecordCpuRocketsDestroyed = true
		} else {
			newRecordCpuRocketsDestroyed = false
		}

		if matchStatsTracker.cpuFastRocketsDestroyed > recordCpuFastRocketsDestroyed {
			recordCpuFastRocketsDestroyed = matchStatsTracker.cpuFastRocketsDestroyed
			newRecordCpuFastRocketsDestroyed = true
		} else {
			newRecordCpuFastRocketsDestroyed = false
		}

		if matchStatsTracker.cpuSmallUfosDestroyed > recordCpuSmallUfosDestroyed {
			recordCpuSmallUfosDestroyed = matchStatsTracker.cpuSmallUfosDestroyed
			newRecordCpuSmallUfosDestroyed = true
		} else {
			newRecordCpuSmallUfosDestroyed = false
		}

		if matchStatsTracker.cpuBigUfosDestroyed > recordCpuBigUfosDestroyed {
			recordCpuBigUfosDestroyed = matchStatsTracker.cpuBigUfosDestroyed
			newRecordCpuBigUfosDestroyed = true
		} else {
			newRecordCpuBigUfosDestroyed = false
		}

		if matchStatsTracker.pauseEnemiesPowerUpsCollected > recordPauseEnemiesPowerUpsCollected {
			recordPauseEnemiesPowerUpsCollected = matchStatsTracker.pauseEnemiesPowerUpsCollected
			newRecordPauseEnemiesPowerUpsCollected = true
		} else {
			newRecordPauseEnemiesPowerUpsCollected = false
		}

		if matchStatsTracker.repairBuildingPowerUpsCollected > recordRepairBuildingPowerUpsCollected {
			recordRepairBuildingPowerUpsCollected = matchStatsTracker.repairBuildingPowerUpsCollected
			newRecordRepairBuildingPowerUpsCollected = true
		} else {
			newRecordRepairBuildingPowerUpsCollected = false
		}

		if matchStatsTracker.destroyEnemiesPowerUpsCollected > recordDestroyEnemiesPowerUpsCollected {
			recordDestroyEnemiesPowerUpsCollected = matchStatsTracker.destroyEnemiesPowerUpsCollected
			newRecordDestroyEnemiesPowerUpsCollected = true
		} else {
			newRecordDestroyEnemiesPowerUpsCollected = false
		}
	}

	private class EncodeContext {
		let file: File.FileHandle

		init(file: File.FileHandle) {
			self.file = file
		}
	}

	private static let statsPath: String = "persistentStats.json"

	private static nonisolated(unsafe) var decodeError:
		@convention(c)
		(UnsafeMutablePointer<json_decoder>?, UnsafePointer<CChar>?, Int32) -> Void = { _, err, line in
			if let e = err.map({ String(cString: $0) }) {
				System.error("JSON error at \(line): \(e)")
			}
		}

	private static nonisolated(unsafe) var didDecodeTableValue:
		@convention(c)
		(UnsafeMutablePointer<json_decoder>?, UnsafePointer<CChar>?, json_value) -> Void = {
			ptr, keyC, val in
			guard
				let ptr = ptr,
				let keyC = keyC,
				let ctxPtr = ptr.pointee.userdata
			else { return }

			let key = String(cString: keyC).utf8

			let stats = Unmanaged<PersistentStats>
				.fromOpaque(ctxPtr)
				.takeUnretainedValue()

			let type = json_value_type(rawValue: numericCast(val.type))

			switch key {
			// Cumulative
			case "sectorsLost":
				stats.sectorsLost = Int(val.data.intval)
			case "timePlayed":
				stats.timePlayed = val.data.floatval
			case "rocketsLaunched":
				stats.rocketsLaunched = Int(val.data.intval)
			case "cpuRocketsDestroyed":
				stats.cpuRocketsDestroyed = Int(val.data.intval)
			case "cpuFastRocketsDestroyed":
				stats.cpuFastRocketsDestroyed = Int(val.data.intval)
			case "cpuSmallUfosDestroyed":
				stats.cpuSmallUfosDestroyed = Int(val.data.intval)
			case "cpuBigUfosDestroyed":
				stats.cpuBigUfosDestroyed = Int(val.data.intval)
			case "pauseEnemiesPowerUpsCollected":
				stats.pauseEnemiesPowerUpsCollected = Int(val.data.intval)
			case "repairBuildingPowerUpsCollected":
				stats.repairBuildingPowerUpsCollected = Int(val.data.intval)
			case "destroyEnemiesPowerUpsCollected":
				stats.destroyEnemiesPowerUpsCollected = Int(val.data.intval)
			// Records
			case "recordTimePlayed":
				stats.recordTimePlayed = val.data.floatval
			case "recordRocketsLaunched":
				stats.recordRocketsLaunched = Int(val.data.intval)
			case "recordCpuRocketsDestroyed":
				stats.recordCpuRocketsDestroyed = Int(val.data.intval)
			case "recordCpuFastRocketsDestroyed":
				stats.recordCpuFastRocketsDestroyed = Int(val.data.intval)
			case "recordCpuSmallUfosDestroyed":
				stats.recordCpuSmallUfosDestroyed = Int(val.data.intval)
			case "recordCpuBigUfosDestroyed":
				stats.recordCpuBigUfosDestroyed = Int(val.data.intval)
			case "recordPauseEnemiesPowerUpsCollected":
				stats.recordPauseEnemiesPowerUpsCollected = Int(val.data.intval)
			case "recordRepairBuildingPowerUpsCollected":
				stats.recordRepairBuildingPowerUpsCollected = Int(val.data.intval)
			case "recordDestroyEnemiesPowerUpsCollected":
				stats.recordDestroyEnemiesPowerUpsCollected = Int(val.data.intval)
			default:
				break
			}
		}

	static nonisolated(unsafe) var writeStringFunc:
		@convention(c) (UnsafeMutableRawPointer?, UnsafePointer<CChar>?, CInt) -> Void = {
			ctxPtr, str, len in
			let file: File.FileHandle = Unmanaged<EncodeContext>
				.fromOpaque(ctxPtr!)
				.takeUnretainedValue()
				.file

			let buffer = UnsafeRawBufferPointer(start: str!, count: Int(len))

			_ = try! file.write(buffer: buffer)
		}
}
