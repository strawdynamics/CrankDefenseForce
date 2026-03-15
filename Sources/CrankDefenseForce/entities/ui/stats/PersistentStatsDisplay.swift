import PlaydateKit

class PersistentStatsDisplay {
	// MARK: Lifecycle

	init(_ config: Config) {
		self.rows = Self.buildRows(config)
		totalHeight = Self.positionRows(self.rows)
	}

	// MARK: Internal

	struct Config {
		let entityStore: EntityStore
	}

	let totalHeight: Int

	func hide() {
		for row in rows {
			for cell in row {
				cell.hide()
			}
		}
	}

	func show() {
		for row in rows {
			for cell in row {
				cell.show()
			}
		}
	}

	// MARK: Private

	private let rows: [[Cell]]

	private static func buildRows(_ config: Config) -> [[Cell]] {
		let pStats = PersistentStats.instance

		var rows: [[Cell]] = []

		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 50
				))
		])

		// Records
		rows.append([
			TextCell(
				TextCell.Config(
					text: "Records",
					font: CdfFont.NicoClean16,
				))
		])

		// Duration, # fired
		let rMinutes = Int(pStats.recordTimePlayed / 60)
		let rSeconds = Int(pStats.recordTimePlayed.truncatingRemainder(dividingBy: 60))
		let rSecondsString = rSeconds < 10 ? "0\(rSeconds)" : "\(rSeconds)"
		rows.append([
			KeyValueCell(
				KeyValueCell.Config(
					key: "Longest match",
					value: "\(rMinutes):\(rSecondsString)",
					rowCellCount: 2
				)),
			KeyValueCell(
				KeyValueCell.Config(
					key: "Most rockets launched",
					value: "\(pStats.recordRocketsLaunched)",
					rowCellCount: 2
				)),
		])

		rows.append([
			TextCell(
				TextCell.Config(
					text: "Enemies destroyed",
				))
		])

		// Destroyed enemy details
		var recordDestroyedEnemiesRow: [Cell] = []

		recordDestroyedEnemiesRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.recordCpuRocketsDestroyed)",
					secondaryText: nil,
					entityType: .rocket,
					entityStore: config.entityStore,
				)))

		recordDestroyedEnemiesRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.recordCpuFastRocketsDestroyed)",
					secondaryText: nil,
					entityType: .fastRocket,
					entityStore: config.entityStore,
				)))

		recordDestroyedEnemiesRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.recordCpuSmallUfosDestroyed)",
					secondaryText: nil,
					entityType: .smallUfo,
					entityStore: config.entityStore,
				)))

		recordDestroyedEnemiesRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.recordCpuBigUfosDestroyed)",
					secondaryText: nil,
					entityType: .bigUfo,
					entityStore: config.entityStore,
				)))

		rows.append(recordDestroyedEnemiesRow)

		// PowerUps collected
		// Header
		rows.append([
			TextCell(
				TextCell.Config(
					text: "Power-ups collected",
				))
		])

		// Collected PowerUp details
		var recordPowerUpsRow: [Cell] = []

		recordPowerUpsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.recordPauseEnemiesPowerUpsCollected)",
					secondaryText: nil,
					entityType: .pauseEnemies,
					entityStore: config.entityStore,
				)))

		recordPowerUpsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.recordRepairBuildingPowerUpsCollected)",
					secondaryText: nil,
					entityType: .repairBuilding,
					entityStore: config.entityStore,
				)))

		recordPowerUpsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.recordDestroyEnemiesPowerUpsCollected)",
					secondaryText: nil,
					entityType: .destroyEnemies,
					entityStore: config.entityStore,
				)))

		rows.append(recordPowerUpsRow)


		// Totals
		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 20
				))
		])
		rows.append([
			HrCell()
		])
		rows.append([
			SpacerCell(
				SpacerCell.Config(
					height: 20
				))
		])

		rows.append([
			TextCell(
				TextCell.Config(
					text: "Totals",
					font: CdfFont.NicoClean16,
				))
		])

		// Duration, # fired
		let minutes = Int(pStats.timePlayed / 60)
		let seconds = Int(pStats.timePlayed.truncatingRemainder(dividingBy: 60))
		let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
		rows.append([
			KeyValueCell(
				KeyValueCell.Config(
					key: "Time played",
					value: "\(minutes):\(secondsString)",
					rowCellCount: 3
				)),
			KeyValueCell(
				KeyValueCell.Config(
					key: "Sectors lost",
					value: "\(pStats.sectorsLost)",
					rowCellCount: 3
				)),
			KeyValueCell(
				KeyValueCell.Config(
					key: "Rockets launched",
					value: "\(pStats.rocketsLaunched)",
					rowCellCount: 3
				)),
		])

		// Enemies destroyed
		let totalEnemiesDestroyed =
			pStats.cpuRocketsDestroyed + pStats.cpuFastRocketsDestroyed + pStats.cpuSmallUfosDestroyed
			+ pStats.cpuBigUfosDestroyed

		// Header
		let pluralizedEnemies = totalEnemiesDestroyed == 1 ? "enemy" : "enemies"

		rows.append([
			TextCell(
				TextCell.Config(
					text: "\(totalEnemiesDestroyed) \(pluralizedEnemies) destroyed",
				))
		])

		// Destroyed enemy details
		var destroyedEnemiesRow: [Cell] = []

		destroyedEnemiesRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.cpuRocketsDestroyed)",
					secondaryText: nil,
					entityType: .rocket,
					entityStore: config.entityStore,
				)))

		destroyedEnemiesRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.cpuFastRocketsDestroyed)",
					secondaryText: nil,
					entityType: .fastRocket,
					entityStore: config.entityStore,
				)))

		destroyedEnemiesRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.cpuSmallUfosDestroyed)",
					secondaryText: nil,
					entityType: .smallUfo,
					entityStore: config.entityStore,
				)))

		destroyedEnemiesRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.cpuBigUfosDestroyed)",
					secondaryText: nil,
					entityType: .bigUfo,
					entityStore: config.entityStore,
				)))

		rows.append(destroyedEnemiesRow)

		// PowerUps collected
		let totalPowerUpsCollected =
			pStats.pauseEnemiesPowerUpsCollected + pStats.repairBuildingPowerUpsCollected
			+ pStats.destroyEnemiesPowerUpsCollected

		// Header
		let pluralizedPowerUps = totalPowerUpsCollected == 1 ? "power-up" : "power-ups"

		rows.append([
			TextCell(
				TextCell.Config(
					text: "\(totalPowerUpsCollected) \(pluralizedPowerUps) collected",
				))
		])

		// Collected PowerUp details
		var powerUpsRow: [Cell] = []

		powerUpsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.pauseEnemiesPowerUpsCollected)",
					secondaryText: nil,
					entityType: .pauseEnemies,
					entityStore: config.entityStore,
				)))

		powerUpsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.repairBuildingPowerUpsCollected)",
					secondaryText: nil,
					entityType: .repairBuilding,
					entityStore: config.entityStore,
				)))

		powerUpsRow.append(
			EntityCell(
				EntityCell.Config(
					text: "\(pStats.destroyEnemiesPowerUpsCollected)",
					secondaryText: nil,
					entityType: .destroyEnemies,
					entityStore: config.entityStore,
				)))

		rows.append(powerUpsRow)

		return rows
	}

	private static func positionRows(_ rows: [[Cell]]) -> Int {
		let offY: Float = 0
		var positionedRowsHeight = 0

		for row in rows {
			let cellCount = row.count
			let cellWidth = Display.width / cellCount
			var positionedCellsWidth = 0

			for (cellIndex, cell) in row.enumerated() {
				cell.moveTo(
					topLeft: Point(
						x: Float(positionedCellsWidth),
						y: offY + Float(positionedRowsHeight),
					))

				positionedCellsWidth += cell.width
			}

			// All cells for a row must be the same height
			positionedRowsHeight += row[0].height
		}

		return positionedRowsHeight
	}
}
